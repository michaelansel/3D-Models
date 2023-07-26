// minVal, maxVal: endpoint dimensions for the measurements; e.g. 0 and pcbWidth
// minLongOffset: measure from origin to far side of connector
// maxLongOffset: measure from maxVal to origin side of connector
// width: width of connector
function calculateCenter(minVal, minLongOffset, width) = minLongOffset - minVal - width/2;
module validateCenter(minVal, maxVal, minLongOffset, maxLongOffset, width, tolerance) {
    center = calculateCenter(minVal, minLongOffset, width);

    centerValidation = maxVal - maxLongOffset + width/2;

    centerError = abs(center - centerValidation);

    // Validate that the dual measurements are consistent
    assert(
      centerError < tolerance,
      "measurements inconsistent"
    );
};

// Parameters
connectorTolerance = 1; // Validate all measurements are within this tolerance and pad holes to match
solderJoints = 1.5; // extra space on the bottom of the PCB for solder joints

// Orientation
// - 0,0 is the corner closest to the barrel connector
// - X-axis is the short side
// - Y-axis is the long side

// Leonardo PCB Dimensions
leonardoPcbWidth = 53.35;
leonardoPcbLength = 67.98; // includes the bump
leonardoPcbThickness = 2;

// Connectors
leonardoUsbXLongOffset = 41.55; // y-axis to far side of connector
leonardoUsbXOpposingOffset = 19.97; // for validation; far side of pcb to near-y-axis side of connector
leonardoUsbWidth = 7.52; // width of connector

leonardoUsbCenter = calculateCenter(0, leonardoUsbXLongOffset, leonardoUsbWidth);
validateCenter(
  0, leonardoPcbWidth,
  leonardoUsbXLongOffset, leonardoUsbXOpposingOffset,
  leonardoUsbWidth,
  connectorTolerance);
 
// This is how big the opening needs to be
microUsbPlugWidth = 10.84;
microUsbPlugHeight = 7.27;
microUsbPlugXOffset = 0; // microUsbPlug is centered on the connector
microUsbPlugYOffset = -1; // microUsbPlug originates 1mm below the bottom of the Leonardo PCB
microUsbPlugYPadding = 3.21; // spacing between microUsbPlug and PCB (this is the metal part of the plug going into the connector with no insulation around it); can have case material in this space as long as it doesn't impede on the actual connector
  
leonardoBarrelXLongOffset = 12.6;
leonardoBarrelXOpposingOffset = 50;
leonardoBarrelWidth = 8.84;
leonardoBarrelHeight = 12.67; // from the bottom of the PCB

leonardoBarrelCenter = calculateCenter(0, leonardoBarrelXLongOffset, leonardoBarrelWidth);
validateCenter(
  0, leonardoPcbWidth,
  leonardoBarrelXLongOffset, leonardoBarrelXOpposingOffset,
  leonardoBarrelWidth,
  connectorTolerance);

leonardoResetXLongOffset = 52.66;
leonardoResetXOpposingOffset = 7.34;
leonardoResetXWidth = 6.54;
leonardoResetYLongOffset = 9.23;
leonardoResetYOpposingOffset = 62.65 + (68.32-65.53); // distance without the nubbin plus the nubbin size
leonardoResetYWidth = 6.07;

leonardoResetXCenter = calculateCenter(0, leonardoResetXLongOffset, leonardoResetXWidth);
validateCenter(
  0, leonardoPcbWidth,
  leonardoResetXLongOffset, leonardoResetXOpposingOffset,
  leonardoResetXWidth,
  connectorTolerance);

leonardoResetYCenter = calculateCenter(0, leonardoResetYLongOffset, leonardoResetYWidth);
validateCenter(
  0, leonardoPcbLength,
  leonardoResetYLongOffset, leonardoResetYOpposingOffset,
  leonardoResetYWidth,
  connectorTolerance);

// X offset (long side), Y offset (short side) for center of hole, and diameter
leonardoDrillHoles = [
  [ 12.49 + 3.43/2, 0.61 + 3.43/2, 3.43 ],
  [ 13.65 + 3.43/2, 48.63 + 3.43/2, 3.43 ],
  [ 64.27 + 3.43/2, 5.8 + 3.43/2, 3.43 ],
  [ 64.12 + 3.43/2, 33.74 + 3.43/2, 3.43 ],
];

// Relative to 0,0 for the shield (so, offset by usbShieldPcbXOffset)
usbShieldDrillHoles = [
  [ 0.84 + 3.7/2, 2.58 + 3.7/2, 3.7 ],
  [ 2.02 + 3.7/2, 49.11 + 3.7/2, 3.7 ],
  [ 49.17 + 3.7/2, 6.11 + 3.7/2, 3.7 ],
  [ 49.21 + 3.7/2, 33.85 + 3.7/2, 3.7 ],
];

// USB Host Shield PCB Dimensions
usbShieldPcbWidth = leonardoPcbWidth; // they match
usbShieldPcbLength = 53.12;
usbShieldPcbThickness = 2;
usbShieldPcbXOffset = leonardoPcbLength - usbShieldPcbLength; // Aligned at the base
usbShieldPcbYOffset = 0;

totalPcbThickness = 14.2; // total thickness for standoffs
totalThickness = 24.09; // from bottom solder joints to top of headers; for validation

usbShieldUsbXLongOffset = 28.32;
usbShieldUsbXOpposingOffset = 38.64;
usbShieldUsbWidth = 13.10;
usbShieldUsbHeight = 5.7;
// all dimensions are technically a bit small because of the wings on the USB A female connector; just pad a little extra to compensate

usbShieldUsbCenter = calculateCenter(0, usbShieldUsbXLongOffset, usbShieldUsbWidth);
validateCenter(
  0, usbShieldPcbWidth,
  usbShieldUsbXLongOffset, usbShieldUsbXOpposingOffset,
  usbShieldUsbWidth,
  connectorTolerance);

usbPlugWidth = 15.42;
usbPlugThickness = 7.78;
usbPlugXOffset = 0;
usbPlugYOffset = 0;
usbPlugYPadding = 5.64;

usbShieldResetXLongOffset = 7.36;
usbShieldResetXOpposingOffset = 51.82;
usbShieldResetXLength = 5.92;
usbShieldResetYLongOffset = 14.10;
usbShieldResetYOpposingOffset = 44.86;
usbShieldResetYLength = 5.83;
usbShieldResetHeight = 5.11 - usbShieldPcbThickness;
usbShieldResetButtonHeight = 6.85 - usbShieldPcbThickness;

usbShieldResetXCenter = calculateCenter(0, usbShieldResetXLongOffset, usbShieldResetXLength);
validateCenter(
  0, usbShieldPcbWidth,
  usbShieldResetXLongOffset, usbShieldResetXOpposingOffset,
  usbShieldResetXLength,
  connectorTolerance);

usbShieldResetYCenter = calculateCenter(0, usbShieldResetYLongOffset, usbShieldResetYLength);
validateCenter(
  0, usbShieldPcbWidth,
  usbShieldResetYLongOffset, usbShieldResetYOpposingOffset,
  usbShieldResetYLength,
  connectorTolerance);

// Ignoring headers for now and just considering them extra thickness in the finished case