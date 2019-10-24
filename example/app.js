// This is a test harness for your module
// You should do something interesting in this harness
// to test out the module and to provide instructions
// to users on how to use it by example.

// open a single window
var win = Ti.UI.createWindow({
  backgroundColor: 'white'
});

// TODO: write your module tests here
var TiAthmovil = require('com.bduyng.tiathmovil');
Ti.API.info('module is => ' + TiAthmovil);

TiAthmovil.addEventListener('error', function onError(e) {
  console.error('Error', e);
});

TiAthmovil.addEventListener('cancelled', function onCancelled(e) {
  Ti.API.warn('Cancelled', e);
});

TiAthmovil.addEventListener('success', function onSuccess(e) {
  console.error('Success');
  console.error(e);
});

TiAthmovil.configure({
  publicToken: 'KAZ2EOUJ0EVGXFDOCKY68TOUKVVN0C8G0TH92F81',
  callbackURL: 'athm-checkout'
});
console.log(TiAthmovil.createCheckoutButton);
var checkoutButton = TiAthmovil.createCheckoutButton({
  width: 300,
  height: 44
});
checkoutButton.addEventListener('frameSizeChanged', function(e) {
  console.log(e);
});
checkoutButton.addEventListener('click', function() {
  TiAthmovil.checkoutWithPayment({
    items: [
      {
        desc: 'description',
        name: 'name',
        price: 15,
        quantity: 1
      }
    ],
    subtotal: 10,
    tax: 10,
    total: 10
  });
});
win.add(checkoutButton);

win.open();
