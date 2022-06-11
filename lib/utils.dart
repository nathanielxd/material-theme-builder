// ignore_for_file: non_constant_identifier_names

import 'dart:math' as math;


int signum(num num) {
  if(num < 0) {
    return -1;
  }
  else if(num == 0) {
    return 0;
  }
  else {
    return 1;
  }
}

num sanitizeDegrees(num degrees) {
  degrees %= 360;
  if(0 > degrees) {
    degrees += 360;
  }
  return degrees;
}

matrixMultiply(List row, List<List> matrix) {
  return [
    row[0] * matrix[0][0] + row[1] * matrix[0][1] + row[2] * matrix[0][2], 
    row[0] * matrix[1][0] + row[1] * matrix[1][1] + row[2] * matrix[1][2], 
    row[0] * matrix[2][0] + row[1] * matrix[2][1] + row[2] * matrix[2][2]
  ];
}

final SRGB_TO_XYZ = [
  [.41233895, .35762064, .18051042],
  [.2126, .7152, .0722],
  [.01932141, .11916382, .95034478]
];

final XYZ_TO_SRGB = [
  [3.2413774792388685, -1.5376652402851851, -.49885366846268053],
  [-.9691452513005321, 1.8758853451067872, .04156585616912061],
  [.05562093689691305, -.20395524564742123, 1.0571799111220335]
];

const WHITE_POINT_D65 = [95.047, 100, 108.883];

argbFromRgb(int red, int green, int blue) {
  return (-16777216 | (red & 255) << 16 | (green & 255) << 8 | blue & 255) >>> 0;
}

argbFromXyz(num x, num y, num z) {
  return argbFromRgb(
    delinearized(XYZ_TO_SRGB[0][0] * x + XYZ_TO_SRGB[0][1] * y + XYZ_TO_SRGB[0][2] * z), 
    delinearized(XYZ_TO_SRGB[1][0] * x + XYZ_TO_SRGB[1][1] * y + XYZ_TO_SRGB[1][2] * z), 
    delinearized(XYZ_TO_SRGB[2][0] * x + XYZ_TO_SRGB[2][1] * y + XYZ_TO_SRGB[2][2] * z)
  );
}

xyzFromArgb(int argb) {
  return matrixMultiply([
    linearized(argb >> 16 & 255), 
    linearized(argb >> 8 & 255), 
    linearized(argb & 255)], 
    SRGB_TO_XYZ
  );
}

labFromArgb(int argb) {
  final linearR = linearized(argb >> 16 & 255);
  final linearG = linearized(argb >> 8 & 255);
  final linearB = linearized(argb & 255);

  final fy = labF(
    (SRGB_TO_XYZ[1][0] * linearR 
    + SRGB_TO_XYZ[1][1] * linearG 
    + SRGB_TO_XYZ[1][2] * linearB) 
    / WHITE_POINT_D65[1]
  );

  return [
    116 * fy - 16, 500 * (labF(
      (SRGB_TO_XYZ[0][0] * linearR 
      + SRGB_TO_XYZ[0][1] * linearG 
      + SRGB_TO_XYZ[0][2] * linearB) 
      / WHITE_POINT_D65[0]) - fy),
    200 * (fy - labF(
      (SRGB_TO_XYZ[2][0] * linearR 
      + SRGB_TO_XYZ[2][1] * linearG 
      + SRGB_TO_XYZ[2][2] * linearB) 
      / WHITE_POINT_D65[2]))
  ];
}

linearized(rgbComponent) {
  final normalized = rgbComponent / 255;
  return 0.040449936 >= normalized 
    ? normalized / 12.92 * 100 
    : 100 * math.pow((normalized + .055) / 1.055, 2.4);
}

int delinearized(num rgbComponent) {
  final normalized = rgbComponent / 100;
  var input = (255 * (.0031308 >= normalized ? 12.92 * normalized : 1.055 * math.pow(normalized, 1 / 2.4) - .055)).round();
  return 0 > input 
    ? 0 
    : (255 < input)
      ? 255 
      : input;
}

num labF(num t) {
  return t > 216 / 24389 
    ? math.pow(t, 1 / 3) 
    : (24389 / 27 * t + 16) / 116;
}

num labInvf(num ft) {
  final ft3 = ft * ft * ft;
  return ft3 > 216 / 24389
    ? ft3 
    : (116 * ft - 16) / (24389 / 27);
}

class ViewingConditions {

  dynamic n, aw, nbb, ncb, c, nc, rgbD, fl, fLRoot, z;

  ViewingConditions(this.n, this.aw, this.nbb, this.ncb, this.c, this.nc, this.rgbD, this.fl, this.fLRoot, this.z);

  factory ViewingConditions.defaultC() {
    var whitePoint = WHITE_POINT_D65;
    var adaptingLuminance = 200 / math.pi * 100 * labInvf(66 / 116) / 100;
    var backgroundLstar = 50;
    var surround = 2;
    var discountingIlluminant = false;

    final rW = .401288 * whitePoint[0] + .650173 * whitePoint[1] + -.051461 * whitePoint[2];
    final gW = - .250268 * whitePoint[0] + 1.204414 * whitePoint[1] + .045854 * whitePoint[2];
    final bW = - .002079 * whitePoint[0] + .048952 * whitePoint[1] + .953127 * whitePoint[2];
    final f = .8 + surround / 10;

    num jsCompilerTemp = 0;

    if(.9 <= f) {
      var amount = 10 * (f - .9);
      jsCompilerTemp = .59 * (1 - amount) + .69 * amount;
    }
    else {
      var amount$jscomp = 10 * (f - .8);
      jsCompilerTemp = .525 * (1 - amount$jscomp) + .59 * amount$jscomp;
    }

    var d = discountingIlluminant ? 1 : f * (1 - 1 / 3.6 * math.exp((-adaptingLuminance - 42) / 92));
    d = 1 < d ? 1 : 0 > d ? 0 : d;

    final 
      rgbD = [100 / rW * d + 1 - d, 100 / gW * d + 1 - d, 100 / bW * d + 1 - d],
      k = 1 / (5 * adaptingLuminance + 1),
      k4 = k * k * k * k,
      k4F = 1 - k4,
      fl = k4 * adaptingLuminance + .1 * k4F * k4F * math.pow(5 * adaptingLuminance, 1/3),
      n = 100 * labInvf((backgroundLstar + 16) / 116) / whitePoint[1],
      nbb = .725 / math.pow(n, .2),
      rgbAFactors = [math.pow(fl * rgbD[0] * rW / 100, .42), math.pow(fl * rgbD[1] * gW / 100, .42), math.pow(fl * rgbD[2] * bW / 100, .42)],
      rgbA = [400 * rgbAFactors[0] / (rgbAFactors[0] + 27.13), 400 * rgbAFactors[1] / (rgbAFactors[1] + 27.13), 400 * rgbAFactors[2] / (rgbAFactors[2] + 27.13)];
  
    return ViewingConditions(
      n, 
      (2 * rgbA[0] + rgbA[1] + .05 * rgbA[2]) * nbb, 
      nbb, 
      nbb, 
      jsCompilerTemp, 
      f, 
      rgbD,
      fl, 
      math.pow(fl, .25), 
      1.48 + math.sqrt(n)
    );
  }
}

fromIntInViewingConditions(argb) {
  final 
    redL = linearized((argb & 16711680) >> 16),
    greenL = linearized((argb & 65280) >> 8),
    blueL = linearized(argb & 255),
    x = .41233895 * redL + .35762064 * greenL + .18051042 * blueL,
    y = .2126 * redL + .7152 * greenL + .0722 * blueL,
    z = .01932141 * redL + .11916382 * greenL + .95034478 * blueL,
    rD = ViewingConditions.defaultC().rgbD[0] * (.401288 * x + .650173 * y - .051461 * z) as num,
    gD = ViewingConditions.defaultC().rgbD[1] * (-.250268 * x + 1.204414 * y + .045854 * z) as num,
    bD = ViewingConditions.defaultC().rgbD[2] * (-.002079 * x + .048952 * y + .953127 * z) as num,
    rAF = math.pow(ViewingConditions.defaultC().fl * rD.abs() / 100, .42),
    gAF = math.pow(ViewingConditions.defaultC().fl * gD.abs() / 100, .42),
    bAF = math.pow(ViewingConditions.defaultC().fl * bD.abs() / 100, .42),
    rA = 400 * signum(rD) * rAF / (rAF + 27.13),
    gA = 400 * signum(gD) * gAF / (gAF + 27.13),
    bA = 400 * signum(bD) * bAF / (bAF + 27.13),
    a = (11 * rA + -12 * gA + bA) / 11,
    b = (rA + gA - 2 * bA) / 9,
    atanDegrees = 180 * math.atan2(b, a) / math.pi,
    hue = 0 > atanDegrees 
      ? atanDegrees + 360 
      : (360 <= atanDegrees)
        ? atanDegrees - 360 
        : atanDegrees,
    hueRadians = hue * math.pi / 180,
    j = 100 * math.pow((40 * rA + 20 * gA + bA) / 20 * ViewingConditions.defaultC().nbb / ViewingConditions.defaultC().aw, ViewingConditions.defaultC().c * ViewingConditions.defaultC().z),
    alpha = math.pow(5E4 / 13 * .25 * (math.cos((20.14 > hue ? hue + 360 : hue) * math.pi / 180 + 2) + 3.8) * ViewingConditions.defaultC().nc * ViewingConditions.defaultC().ncb * math.sqrt(a * a + b * b) / ((20 * rA + 20 * gA + 21 * bA) / 20 + .305), .9) * math.pow(1.64 - math.pow(.29, ViewingConditions.defaultC().n), .73),
    c = alpha * math.sqrt(j / 100),
    mstar = 1 / .0228 * math.log(1 + .0228 * c * ViewingConditions.defaultC().fLRoot);

  return Hct$cam16$Cam16(hue, c, j, 4 / ViewingConditions.defaultC().c * math.sqrt(j / 100) * (ViewingConditions.defaultC().aw +
    4) * ViewingConditions.defaultC().fLRoot, 50 * math.sqrt(alpha * ViewingConditions.defaultC().c / (ViewingConditions.defaultC().aw + 4)), (1 + 100 * .007) * j / (1 + .007 * j), mstar * math.cos(hueRadians), mstar * math.sin(hueRadians));
}

class Hct$cam16$Cam16 {

  dynamic hue, chroma, j, q, s, jstar, astar, bstar;

  Hct$cam16$Cam16(this.hue, this.chroma, this.j, this.q, this.s, this.jstar, this.astar, this.bstar);

  num distance(Hct$cam16$Cam16 other) {
    final 
      dJ = jstar - other.jstar,
      dA = astar - other.astar,
      dB = bstar - other.bstar;
    return 1.41 * math.pow(math.sqrt(dJ * dJ + dA * dA + dB * dB), .63);
  }

  toInt() {
    final 
      t = math.pow((0 == chroma || 0 == j ? 0 : chroma / math.sqrt(j / 100)) / math.pow(1.64 - math.pow(.29, ViewingConditions.defaultC().n), .73), 1 / .9),
      hRad = hue * math.pi / 180,    
      p2 = ViewingConditions.defaultC().aw * math.pow(j / 100, 1 / ViewingConditions.defaultC().c / ViewingConditions.defaultC().z) / ViewingConditions.defaultC().nbb,
      hSin = math.sin(hRad),
      hCos = math.cos(hRad),
      gamma = 23 * (p2 + .305) * t / (5E4 / 13 * (math.cos(hRad + 2) + 3.8) * 5.75 * ViewingConditions.defaultC().nc * ViewingConditions.defaultC().ncb + 11 * t * hCos + 108 * t * hSin),
      a = gamma * hCos,
      b = gamma * hSin,
      rA = (460 * p2 + 451 * a + 288 * b) / 1403,
      gA = (460 * p2 - 891 * a - 261 * b) / 1403,
      bA = (460 * p2 - 220 * a - 6300 * b) / 1403,
      rF = 100 / ViewingConditions.defaultC().fl * signum(rA) * math.pow(math.max(0, 27.13 * rA.abs() / (400 - rA.abs())), 1 / .42) / ViewingConditions.defaultC().rgbD[0],
      gF = 100 / ViewingConditions.defaultC().fl * signum(gA) * math.pow(math.max(0, 27.13 * gA.abs() / (400 - gA.abs())), 1 / .42) / ViewingConditions.defaultC().rgbD[1],
      bF = 100 / ViewingConditions.defaultC().fl * signum(bA) * math.pow(math.max(0, 27.13 * bA.abs() / (400 - bA.abs())), 1 / .42) / ViewingConditions.defaultC().rgbD[2];
      
    return argbFromXyz(1.86206786 * rF - 1.01125463 * gF + .14918677 * bF, .38752654 * rF + .62144744 * gF - .00897398 * bF, -.0158415 * rF - .03412294 * gF + 1.04996444 * bF);
  }
}

num sanitizeRadians(num angle) {
  return (angle + 8 * math.pi) % (2 * math.pi);
}

num trueDelinearized(num rgbComponent) {
  final normalized = rgbComponent / 100;
  return 255 * (.0031308 >= normalized ? 12.92 * normalized : 1.055 * math.pow(normalized, 1 / 2.4) - .055);
}

chromaticAdaptation(num component) {
  final af = math.pow(component.abs(), .42);
  return 400 * signum(component) * af / (af + 27.13);
}

hueOf(linrgb) {
  final scaledDiscount = matrixMultiply(linrgb, SCALED_DISCOUNT_FROM_LINRGB),
    rA = chromaticAdaptation(scaledDiscount[0]),
    gA = chromaticAdaptation(scaledDiscount[1]),
    bA = chromaticAdaptation(scaledDiscount[2]);
  return math.atan2((rA + gA - 2 * bA) / 9, (11 * rA + -12 * gA + bA) / 11);
}

bool isBounded(num x) {
  return 0 <= x && 100 >= x;
}

num inverseChromaticAdaptation(num adapted) {
  final adaptedAbs = adapted.abs();
  return signum(adapted) * math.pow(math.max(0, 27.13 * adaptedAbs / (400 - adaptedAbs)), 1 / .42);
}

solveToInt(hueDegrees, chroma, lstar) {
  if (1E-4 > chroma || 1E-4 > lstar || 99.9999 < lstar) {
    final component = delinearized(100 * labInvf((lstar + 16) / 116));
    return argbFromRgb(component, component, component);
  }

  hueDegrees = sanitizeDegrees(hueDegrees);
  final hueRadians = hueDegrees / 180 * math.pi,
  y = 100 * labInvf((lstar + 16) / 116);

  var JSCompiler_inline_result = 0;

  a: {
    var j = 11 * math.sqrt(y);
    final tInnerCoeff = 1 / math.pow(1.64 - math.pow(.29, ViewingConditions.defaultC().n), .73),
      p1 = 5E4 / 13 * (math.cos(hueRadians + 2) + 3.8) * .25 * ViewingConditions.defaultC().nc * ViewingConditions.defaultC().ncb,
      hSin = math.sin(hueRadians),
      hCos = math.cos(hueRadians);

      for (int iterationRound = 0; 5 > iterationRound; iterationRound++) {
        final jNormalized = j / 100,
          t = math.pow((0 == chroma || 0 == j ? 0 : chroma / math.sqrt(jNormalized)) * tInnerCoeff, 1 / .9),
          p2 = ViewingConditions.defaultC().aw * math.pow(jNormalized, 1 / ViewingConditions.defaultC().c / ViewingConditions.defaultC().z) / ViewingConditions.defaultC().nbb,
          gamma = 23 * (p2 + .305) * t / (23 * p1 + 11 * t * hCos + 108 * t * hSin),
          a = gamma * hCos,
          b = gamma * hSin,
          linrgb = matrixMultiply([
            inverseChromaticAdaptation((460 * p2 + 451 * a + 288 * b) / 1403), 
            inverseChromaticAdaptation((460 * p2 - 891 * a - 261 * b) / 1403), 
            inverseChromaticAdaptation((460 * p2 - 220 * a - 6300 * b) / 1403)
          ], LINRGB_FROM_SCALED_DISCOUNT);

        if (0 > linrgb[0] || 0 > linrgb[1] || 0 > linrgb[2]) break;
        final num fnj = Y_FROM_LINRGB[0] * linrgb[0] + Y_FROM_LINRGB[1] * linrgb[1] + Y_FROM_LINRGB[2] * linrgb[2];
        if (0 >= fnj) break;
        if (4 == iterationRound || .002 > (fnj - y).abs()) {
          if (100.01 < linrgb[0] || 100.01 < linrgb[1] || 100.01 < linrgb[2]) break;
            JSCompiler_inline_result = argbFromRgb(delinearized(linrgb[0]), delinearized(linrgb[1]), delinearized(linrgb[2]));
            break a;
        }
        j -= (fnj - y) * j / (2 * fnj);
      }
  }
  
  final exactAnswer = JSCompiler_inline_result;
  if (0 != exactAnswer) return exactAnswer;

  final kR = Y_FROM_LINRGB[0],
  kG = Y_FROM_LINRGB[1],
  kB = Y_FROM_LINRGB[2],
  points = [
    [y / kR, 0, 0],
    [(y - 100 * kB) / kR, 0, 100],
    [(y - 100 * kG) / kR, 100, 0],
    [(y - 100 * kB - 100 * kG) / kR,
        100, 100
    ],
    [0, y / kG, 0],
    [100, (y - 100 * kR) / kG, 0],
    [0, (y - 100 * kB) / kG, 100],
    [100, (y - 100 * kR - 100 * kB) / kG, 100],
    [0, 0, y / kB],
    [100, 0, (y - 100 * kR) / kB],
    [0, 100, (y - 100 * kG) / kB],
    [100, 100, (y - 100 * kR - 100 * kG) / kB]
  ],

  ans = [];

  for (var point in points) {
    if(isBounded(point[0]) && isBounded(point[1]) && isBounded(point[2])) {
      ans.add(point);
    }
  }

  var left = ans[0],
    right = left,
    leftHue = hueOf(left),
    rightHue = leftHue,
    uncut = true;
  
  for (var i = 1; i < ans.length; i++) {
    final mid = ans[i], midHue = hueOf(mid);
    if (uncut || sanitizeRadians(midHue - leftHue) < sanitizeRadians(rightHue - leftHue)) {
      uncut = false;
      if(sanitizeRadians(hueRadians - leftHue) < sanitizeRadians(midHue - leftHue)) {
        right = mid;
        rightHue = midHue;
      }
      else {
        left = mid;
        leftHue = midHue;
      }
    }
  }
    
  var JSCompiler_inline_result$jscomp$0 = [left, right];
  var left$jscomp$0 = JSCompiler_inline_result$jscomp$0[0],
  leftHue$jscomp$0 = hueOf(left$jscomp$0),
  right$jscomp$0 = JSCompiler_inline_result$jscomp$0[1];

  var JSCompiler_inline_result$jscomp$2;

  for (var axis = 0; 3 > axis; axis++) {
    if (left$jscomp$0[axis] != right$jscomp$0[axis]) {
      num lPlane, rPlane;

      if(left$jscomp$0[axis] < right$jscomp$0[axis]) {
        lPlane = (trueDelinearized(left$jscomp$0[axis]) - .5).floor();
        rPlane = (trueDelinearized(right$jscomp$0[axis]) - .5).ceil();
      }
      else {
        lPlane = (trueDelinearized(left$jscomp$0[axis]) - .5).ceil();
        rPlane = (trueDelinearized(right$jscomp$0[axis]) - .5).floor();
      }

      for (var i = 0; 8 > i && !(1 >= (rPlane - lPlane).abs()); i++) {
        final mPlane = ((lPlane + rPlane) / 2).floor();
        var source = left$jscomp$0[axis];
        var JSCompiler_inline_result$jscomp$1 = (CRITICAL_PLANES[mPlane] - source) / (right$jscomp$0[axis] - source);

        final mid = [
          left$jscomp$0[0] + (right$jscomp$0[0] - left$jscomp$0[0]) * JSCompiler_inline_result$jscomp$1, 
          left$jscomp$0[1] + (right$jscomp$0[1] - left$jscomp$0[1]) * JSCompiler_inline_result$jscomp$1, 
          left$jscomp$0[2] + (right$jscomp$0[2] - left$jscomp$0[2]) * JSCompiler_inline_result$jscomp$1
        ];
        final midHue = hueOf(mid);

        if(sanitizeRadians(hueRadians - leftHue$jscomp$0) < sanitizeRadians(midHue - leftHue$jscomp$0)) {
          right$jscomp$0 = mid;
          rPlane = mPlane;
        }
        else {
          left$jscomp$0 = mid;
          leftHue$jscomp$0 = midHue;
          lPlane = mPlane;
        }
      }
    }
    JSCompiler_inline_result$jscomp$2 = [
      (left$jscomp$0[0] + right$jscomp$0[0]) / 2, 
      (left$jscomp$0[1] + right$jscomp$0[1]) / 2, 
      (left$jscomp$0[2] + right$jscomp$0[2]) / 2
    ];
  }
  
  return argbFromRgb(
    delinearized(JSCompiler_inline_result$jscomp$2[0]),
    delinearized(JSCompiler_inline_result$jscomp$2[1]), 
    delinearized(JSCompiler_inline_result$jscomp$2[2])
  );
}

const SCALED_DISCOUNT_FROM_LINRGB = [
  [.001200833568784504, .002389694492170889, 2.795742885861124E-4],
  [5.891086651375999E-4, .0029785502573438758,
      3.270666104008398E-4
  ],
  [1.0146692491640572E-4, 5.364214359186694E-4, .0032979401770712076]
];

const LINRGB_FROM_SCALED_DISCOUNT = [
  [1373.2198709594231, -1100.4251190754821, -7.278681089101213],
  [-271.815969077903, 559.6580465940733, -32.46047482791194],
  [1.9622899599665666, -57.173814538844006, 308.7233197812385]
];

const Y_FROM_LINRGB = [.2126, .7152, .0722];
const CRITICAL_PLANES = [.015176349177441876, .045529047532325624, .07588174588720938, .10623444424209313, .13658714259697685, .16693984095186062, .19729253930674434, .2276452376616281, .2579979360165119, .28835063437139563, .3188300904430532, .350925934958123, .3848314933096426, .42057480301049466, .458183274052838, .4976837250274023, .5391024159806381, .5824650784040898, .6277969426914107, .6751227633498623,
  .7244668422128921, .775853049866786, .829304845476233, .8848452951698498, .942497089126609, 1.0022825574869039, 1.0642236851973577, 1.1283421258858297, 1.1946592148522128, 1.2631959812511864, 1.3339731595349034, 1.407011200216447, 1.4823302800086415, 1.5599503113873272, 1.6398909516233677, 1.7221716113234105, 1.8068114625156377, 1.8938294463134073, 1.9832442801866852, 2.075074464868551, 2.1693382909216234, 2.2660538449872063, 2.36523901573795, 2.4669114995532007, 2.5710888059345764, 2.6777882626779785, 2.7870270208169257,
  2.898822059350997, 3.0131901897720907, 3.1301480604002863, 3.2497121605402226, 3.3718988244681087, 3.4967242352587946, 3.624204428461639, 3.754355295633311, 3.887192587735158, 4.022731918402185, 4.160988767090289, 4.301978482107941, 4.445716283538092, 4.592217266055746, 4.741496401646282, 4.893568542229298, 5.048448422192488, 5.20615066083972, 5.3666897647573375, 5.5300801301023865, 5.696336044816294, 5.865471690767354, 6.037501145825082, 6.212438385869475, 6.390297286737924, 6.571091626112461, 6.7548350853498045, 6.941541251256611,
  7.131223617812143, 7.323895587840543, 7.5195704746346665, 7.7182615035334345, 7.919981813454504, 8.124744458384042, 8.332562408825165, 8.543448553206703, 8.757415699253682, 8.974476575321063, 9.194643831691977, 9.417930041841839, 9.644347703669503, 9.873909240696694, 10.106627003236781, 10.342513269534024, 10.58158024687427, 10.8238400726681, 11.069304815507364, 11.317986476196008, 11.569896988756009, 11.825048221409341, 12.083451977536606, 12.345119996613247, 12.610063955123938, 12.878295467455942, 13.149826086772048, 13.42466730586372,
  13.702830557985108, 13.984327217668513, 14.269168601521828, 14.55736596900856, 14.848930523210871, 15.143873411576273, 15.44220572664832, 15.743938506781891, 16.04908273684337, 16.35764934889634, 16.66964922287304, 16.985093187232053, 17.30399201960269, 17.62635644741625, 17.95219714852476, 18.281524751807332, 18.614349837764564, 18.95068293910138, 19.290534541298456, 19.633915083172692, 19.98083495742689, 20.331304511189067, 20.685334046541502, 21.042933821039977, 21.404114048223256, 21.76888489811322, 22.137256497705877,
  22.50923893145328, 22.884842241736916, 23.264076429332462, 23.6469514538663, 24.033477234264016, 24.42366364919083, 24.817520537484558, 25.21505769858089, 25.61628489293138, 26.021211842414342, 26.429848230738664, 26.842203703840827, 27.258287870275353, 27.678110301598522, 28.10168053274597, 28.529008062403893, 28.96010235337422, 29.39497283293396, 29.83362889318845, 30.276079891419332, 30.722335150426627, 31.172403958865512, 31.62629557157785, 32.08401920991837, 32.54558406207592, 33.010999283389665, 33.4802739966603, 33.953417292456834,
  34.430438229418264, 34.911345834551085, 35.39614910352207, 35.88485700094671, 36.37747846067349, 36.87402238606382, 37.37449765026789, 37.87891309649659, 38.38727753828926, 38.89959975977785, 39.41588851594697, 39.93615253289054, 40.460400508064545, 40.98864111053629, 41.520882981230194, 42.05713473317016, 42.597404951718396, 43.141702194811224, 43.6900349931913, 44.24241185063697, 44.798841244188324, 45.35933162437017, 45.92389141541209, 46.49252901546552, 47.065252796817916, 47.64207110610409, 48.22299226451468, 48.808024568002054,
  49.3971762874833, 49.9904556690408, 50.587870934119984, 51.189430279724725, 51.79514187861014, 52.40501387947288, 53.0190544071392, 53.637271562750364, 54.259673423945976, 54.88626804504493, 55.517063457223934, 56.15206766869424, 56.79128866487574, 57.43473440856916, 58.08241284012621, 58.734331877617365, 59.39049941699807, 60.05092333227251, 60.715611475655585, 61.38457167773311, 62.057811747619894, 62.7353394731159, 63.417162620860914, 64.10328893648692, 64.79372614476921, 65.48848194977529, 66.18756403501224, 66.89098006357258,
  67.59873767827808, 68.31084450182222, 69.02730813691093, 69.74813616640164, 70.47333615344107, 71.20291564160104, 71.93688215501312, 72.67524319850172, 73.41800625771542, 74.16517879925733, 74.9167682708136, 75.67278210128072, 76.43322770089146, 77.1981124613393, 77.96744375590167, 78.74122893956174, 79.51947534912904, 80.30219030335869, 81.08938110306934, 81.88105503125999, 82.67721935322541, 83.4778813166706, 84.28304815182372, 85.09272707154808, 85.90692527145302, 86.72564993000343, 87.54890820862819, 88.3767072518277, 89.2090541872801,
  90.04595612594655, 90.88742016217518, 91.73345337380438, 92.58406282226491, 93.43925555268066, 94.29903859396902, 95.16341895893969, 96.03240364439274, 96.9059996312159, 97.78421388448044, 98.6670533535366, 99.55452497210776
];