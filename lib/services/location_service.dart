import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';


abstract class CoordenadaServico {
  Future<Position?> obterPosicaoAtual();
  Stream<Position> escutarFluxoPosicao();
}

class ServicoCoordenada implements CoordenadaServico {
  @override
  Future<Position?> obterPosicaoAtual() async {
    try {
      bool servicoHabilitado;
      LocationPermission permissao;

  
      servicoHabilitado = await Geolocator.isLocationServiceEnabled();
      if (!servicoHabilitado) {
        if (kDebugMode) {
          debugPrint('Serviço de coordenada desativado');
        }
        return null;
      }


      permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
        if (permissao == LocationPermission.denied) {
          if (kDebugMode) {
            debugPrint('Permissão para coordenada negada');
          }
          return null;
        }
      }

      if (permissao == LocationPermission.deniedForever) {
        if (kDebugMode) {
          debugPrint('Permissão permanentemente negada para coordenada');
        }
        return null;
      }

      final bateria = Battery();
      int nivelBateria;
      try {
        nivelBateria = await bateria.batteryLevel;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Erro ao obter nível da bateria: $e');
        }
        nivelBateria = 100;
      }

    
      LocationAccuracy precisao;
      switch (nivelBateria) {
        case > 50:
          precisao = LocationAccuracy.best;
          break;
        case > 30:
          precisao = LocationAccuracy.high;
          break;
        case > 20:
          precisao = LocationAccuracy.medium;
          break;
        default:
          precisao = LocationAccuracy.low;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: precisao,
          distanceFilter: 10,
          timeLimit: const Duration(seconds: 15),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao tentar localizar posição: $e');
      }
      return null;
    }
  }

  @override
  Stream<Position> escutarFluxoPosicao() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
