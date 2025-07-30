// lib/pages/light_meter_page.dart

import 'dart:async'; // Hatalı import düzeltildi
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:light_sensor/light_sensor.dart'; // Doğru paket
import 'package:plantpal/theme/app_theme.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class LightMeterPage extends StatefulWidget {
  const LightMeterPage({super.key});

  @override
  State<LightMeterPage> createState() => _LightMeterPageState();
}

class _LightMeterPageState extends State<LightMeterPage> {
  int _luxValue = 0;
  String _lightLevel = "Ölçüm yapılıyor...";
  Color _indicatorColor = Colors.grey;
  StreamSubscription? _subscription;
  bool _hasSensor = true;

  @override
  void initState() {
    super.initState();
    initSensor();
  }

  Future<void> initSensor() async {
    // hasSensor da bir metot olduğu için () parantezleri eklendi.
    bool hasSensor = await LightSensor.hasSensor();
    if (!hasSensor) {
      if(mounted) {
        setState(() {
          _hasSensor = false;
          _lightLevel = "Cihazınızda ışık sensörü bulunmuyor.";
        });
      }
      return;
    }
    
    // --- KESİN HATA DÜZELTMESİ BURADA ---
    // 'luxStream' bir fonksiyon olduğu için () parantezleri ile çağrılmalı.
    _subscription = LightSensor.luxStream().listen((int luxValue) {
      if (mounted) {
        setState(() {
          _luxValue = luxValue;
          _updateLightLevel(luxValue);
        });
      }
    });
  }

  void _updateLightLevel(int lux) {
    if (lux < 1000) {
      _lightLevel = "Düşük Işık";
      _indicatorColor = Colors.blue.shade300;
    } else if (lux < 10000) {
      _lightLevel = "Orta (Dolaylı) Işık";
      _indicatorColor = Colors.green.shade400;
    } else {
      _lightLevel = "Yüksek (Parlak) Işık";
      _indicatorColor = Colors.orange.shade500;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Işık Seviyesi Ölçer'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: !_hasSensor 
        ? Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(_lightLevel, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
          )
        : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 40000,
                    showLabels: false,
                    showTicks: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.15,
                      cornerStyle: CornerStyle.bothCurve,
                      color: Colors.grey.shade300,
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    pointers: <GaugePointer>[
                      RangePointer(
                        value: _luxValue.toDouble(),
                        cornerStyle: CornerStyle.bothCurve,
                        width: 0.15,
                        sizeUnit: GaugeSizeUnit.factor,
                        color: _indicatorColor,
                        enableAnimation: true,
                        animationDuration: 450,
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _luxValue.toString(),
                              style: GoogleFonts.montserrat(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryText,
                              ),
                            ),
                            Text(
                              "Lüks",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                color: AppTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        angle: 90,
                        positionFactor: 0.1,
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 48),
              Text(
                _lightLevel,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _indicatorColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Doğru ölçüm için telefonunuzun ön kamera ve ahize kısmını ışık kaynağına doğru tutun.",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: AppTheme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}