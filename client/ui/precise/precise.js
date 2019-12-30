function UpdatePosition(x, y, z) {
  let pX = document.getElementById('x');
  pX.value = x;

  let pY = document.getElementById('y');
  pY.value = y;

  let pZ = document.getElementById('z');
  pZ.value = z;
}

function UpdateRotation(x, y, z) {
  let pX = document.getElementById('rx');
  pX.value = x;

  let pY = document.getElementById('ry');
  pY.value = y;

  let pZ = document.getElementById('rz');
  pZ.value = z;
}

function UpdateScale(x, y, z) {
  let pX = document.getElementById('sx');
  pX.value = x;

  let pY = document.getElementById('sy');
  pY.value = y;

  let pZ = document.getElementById('sz');
  pZ.value = z;
}

function SendPosition() {
  let pX = document.getElementById('x');
  let pY = document.getElementById('y');
  let pZ = document.getElementById('z');

  CallEvent('UpdateSelectedPosition', pX.value, pY.value, pZ.value)
}

function SendRotation() {
  let pX = document.getElementById('rx');
  let pY = document.getElementById('ry');
  let pZ = document.getElementById('rz');

  CallEvent('UpdateSelectedRotation', pX.value, pY.value, pZ.value)
}

function SendScale() {
  let pX = document.getElementById('sx');
  let pY = document.getElementById('sy');
  let pZ = document.getElementById('sz');

  CallEvent('UpdateSelectedScale', pX.value, pY.value, pZ.value)
}

OnDocumentReady(function() {
  //--- Position
  let pX = document.getElementById('x');
  pX.onchange = SendPosition;

  let pY = document.getElementById('y');
  pY.onchange = SendPosition;

  let pZ = document.getElementById('z');
  pZ.onchange = SendPosition;

  //--- Rotation
  let rX = document.getElementById('rx');
  rX.onchange = SendRotation;

  let rY = document.getElementById('ry');
  rY.onchange = SendRotation;

  let rZ = document.getElementById('rz');
  rZ.onchange = SendRotation;

  //--- Scale
  let sX = document.getElementById('sx');
  sX.onchange = SendScale;

  let sY = document.getElementById('sy');
  sY.onchange = SendScale;

  let sZ = document.getElementById('sz');
  sZ.onchange = SendScale;
});