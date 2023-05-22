wallThickness = 3.0;
boardLength = 96.4;
boardWidth = 65.5;
boardHeight = 15.0;
leadProtrusion = 5.0;
lidHeight = 3.0;
lidCutout = 20.2;
boardLip = 2.0;
lidLip = 2.0;
lidLipHeight = 2.0;
lidCutaway = 20.2;
batteryLength = 70.0;
batteryWidth = 60.2;
batteryHeight = 9.0;
barrelJackOffset = 18.9;
barrelJackWidth = 10.0;
barrelJackHeight = 10.9;
pcbThickness = 2.5;
usbCOffset = 6.1;
usbCWidth = 9.1;
usbCHeight = 3.5;
usbCHeightOffset = 3.7;

showCase = false;
showLid = true;

lidHoverHeight = 20.0;

delta = 0.001;

overallHeight = boardHeight + leadProtrusion + batteryHeight + wallThickness + lidHeight;
pcbSurfaceHeight = wallThickness + pcbThickness + batteryHeight + leadProtrusion;

lidBaseHeight = showLid && !showCase ? 0 : overallHeight + lidHeight + lidHoverHeight;

// case
if (showCase) difference() {
    // base cube
    cube([boardLength + 2*wallThickness, boardWidth + 2*wallThickness, overallHeight]);
    // lid
    translate([wallThickness - lidLip, wallThickness - lidLip, overallHeight - lidHeight]) cube([boardLength + 2*lidLip, boardWidth + 2*lidLip, lidHeight + delta]);
    // pcb area
    translate([wallThickness, wallThickness, overallHeight - lidHeight - boardHeight]) cube([boardLength, boardWidth, boardHeight + delta]);
    // battery area
    translate([(boardLength - batteryLength) / 2 + wallThickness, (boardWidth - batteryWidth) / 2 + wallThickness, wallThickness]) cube([batteryLength, batteryWidth, batteryHeight + leadProtrusion + delta]);
    // barrel jack cutout
    translate([0 - delta, wallThickness + barrelJackOffset, pcbSurfaceHeight]) cube([wallThickness + 2*delta, barrelJackWidth, barrelJackHeight + delta]); 
    // USB-C port cutout
    translate([usbCOffset, wallThickness + boardWidth - delta, pcbSurfaceHeight + usbCHeightOffset]) cube([usbCWidth, wallThickness + 2*delta, usbCHeight]);
}

// lid
if (showLid) translate([0, 0, lidBaseHeight]) difference() {
    // base area
    cube([boardLength + 2*wallThickness, boardWidth + 2*wallThickness, lidHeight]);
    // edges to fit into case
    translate([0 - delta, 0 - delta, lidHeight - lidLipHeight]) cube([boardLength + 2*wallThickness + 2*delta, lidLip, lidLipHeight + delta]);
    translate([0 - delta, boardWidth + 2*wallThickness - lidLip + delta, lidHeight - lidLipHeight]) cube([boardLength + 2*wallThickness + 2*delta, lidLip, lidLipHeight + delta]);
    translate([0 - delta, 0 - delta, lidHeight - lidLipHeight]) cube([lidLip, boardWidth + 2*wallThickness + 2*delta, lidLipHeight + delta]);
    translate([boardLength + 2*wallThickness - lidLip + delta, 0 - delta, lidHeight - lidLipHeight]) cube([lidLip, boardWidth + 2*wallThickness + 2*delta, lidLipHeight + delta]);
    // cutaway for access to ports
    translate([boardLength + wallThickness - lidCutaway + delta, 0 - delta, 0 - delta]) cube([lidCutaway + wallThickness + delta, boardWidth + 2*wallThickness + 2*delta, lidHeight + 2*delta]);
}

