import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();
const db = admin.firestore();

// Trigger: On order status change → recalculate shop fulfillment rate
export const onOrderUpdate = functions.firestore
  .document('orders/{orderId}')
  .onWrite(async (change, context) => {
    const order = change.after.exists ? change.after.data() : null;
    if (!order) return;

    const shopId = order.shopId;
    const successfulStatuses = ['confirmed', 'delivered', 'completed'];

    const snapshot = await db
      .collection('orders')
      .where('shopId', '==', shopId)
      .get();

    let totalOrders = 0;
    let successfulOrders = 0;

    snapshot.forEach((doc) => {
      const status = doc.data().status;
      if (status === 'pending' || status === 'confirmed' || status === 'delivered' || status === 'completed' || status === 'cancelled') {
        totalOrders++;
        if (successfulStatuses.includes(status)) {
          successfulOrders++;
        }
      }
    });

    const rate = totalOrders > 0 ? (successfulOrders / totalOrders) * 100 : 100;

    await db.collection('shops').doc(shopId).update({
      fulfillmentRate: Math.round(rate * 100) / 100,
      totalOrders: totalOrders,
      successfulOrders: successfulOrders,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info(`Fulfillment rate updated for shop ${shopId}: ${rate}%`);
  });

// Trigger: On order create → send push notification to shop owner
export const onOrderCreate = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();

    const shopDoc = await db.collection('shops').doc(order.shopId).get();
    if (!shopDoc.exists) return;
    const shop = shopDoc.data()!;

    const ownerDoc = await db.collection('users').doc(shop.ownerId).get();
    if (!ownerDoc.exists) return;
    const owner = ownerDoc.data()!;

    const fcmToken = owner.fcmToken;
    if (!fcmToken) return;

    const message = {
      token: fcmToken,
      notification: {
        title: 'New Order',
        body: `Order #${snap.id.substring(0, 8)} — ${order.totalAmount} JOD`,
      },
      data: {
        route: '/owner/orders/' + snap.id,
        type: 'new_order',
      },
    };

    try {
      await admin.messaging().send(message);
      functions.logger.info('Notification sent to shop owner', { shopId: order.shopId });
    } catch (e) {
      functions.logger.warn('Failed to send notification', e);
    }
  });

// Scheduled: Auto-cancel orders pending > 2 hours
export const autoCancelOrders = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    const twoHoursAgo = new Date(Date.now() - 2 * 60 * 60 * 1000);

    const snapshot = await db
      .collection('orders')
      .where('status', '==', 'pending')
      .where('createdAt', '<', twoHoursAgo)
      .get();

    if (snapshot.empty) {
      functions.logger.info('No orders to auto-cancel');
      return;
    }

    const batch = db.batch();
    const notificationData: Array<{ orderId: string; customerId: string; shopId: string; category: string }> = [];

    snapshot.forEach((doc) => {
      batch.update(doc.ref, {
        status: 'cancelled',
        autoCancelled: true,
        respondedAt: admin.firestore.FieldValue.serverTimestamp(),
        cancellationReason: 'Auto-cancelled: no response within 2 hours',
      });

      const data = doc.data();
      // Get category from first item for similar items suggestion
      const firstItem = data.items?.[0];
      notificationData.push({
        orderId: doc.id,
        customerId: data.customerId,
        shopId: data.shopId,
        category: firstItem?.category || '',
      });
    });

    await batch.commit();
    functions.logger.info(`Auto-cancelled ${snapshot.size} orders`);

    // Send notifications to customers about cancellation + similar items
    for (const nd of notificationData) {
      const customerDoc = await db.collection('users').doc(nd.customerId).get();
      if (!customerDoc.exists) continue;
      const customer = customerDoc.data()!;
      const fcmToken = customer.fcmToken;
      if (!fcmToken) continue;

      const message = {
        token: fcmToken,
        notification: {
          title: 'Order Cancelled',
          body: 'Your order was auto-cancelled. Find similar items from other shops.',
        },
        data: {
          route: `/customer/similar-items?category=${nd.category}&excludeShopId=${nd.shopId}`,
          type: 'auto_cancelled',
        },
      };

      try {
        await admin.messaging().send(message);
      } catch (e) {
        functions.logger.warn('Failed to send cancellation notification', e);
      }
    }
  });
