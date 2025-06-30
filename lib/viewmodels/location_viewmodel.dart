import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../services/servico_coordenada.dart'; 

class CoordenadaControle extends ChangeNotifier {
  final ServicoCoordenada _coordenadaServico = ServicoCoordenada();

  Position? _coordenadaAtual;
  bool _carregando = true;
  bool _possuiErro = false;
  String _mensagemErro = '';
  StreamSubscription<Position>? _fluxoCoordenadas;

  Position? get coordenadaAtual => _coordenadaAtual;
  bool get carregando => _carregando;
  bool get possuiErro => _possuiErro;
  String get mensagemErro => _mensagemErro;

  Future<void> buscarCoordenada() async {
    _carregando = true;
    _possuiErro = false;
    _mensagemErro = '';
    notifyListeners();

    try {
      _coordenadaAtual = await _coordenadaServico.obterPosicaoAtual();

      if (_coordenadaAtual == null) {
        _possuiErro = true;
        _mensagemErro = 'Não foi possível acessar a posição. Verifique permissões ou GPS.';
      } else {
        _iniciarMonitoramento();
      }
    } catch (e) {
      _possuiErro = true;
      _mensagemErro = 'Erro ao tentar localizar coordenada: ${e.toString()}';
    }

    _carregando = false;
    notifyListeners();
  }

  void _iniciarMonitoramento() {
    _fluxoCoordenadas?.cancel();
    _fluxoCoordenadas = _coordenadaServico.escutarFluxoPosicao().listen(
      (Position novaCoordenada) {
        _coordenadaAtual = novaCoordenada;
        _possuiErro = false;
        _mensagemErro = '';
        notifyListeners();
      },
      onError: (erro) {
        if (kDebugMode) {
          debugPrint('Erro no acompanhamento de coordenadas: $erro');
        }
        _possuiErro = true;
        _mensagemErro = 'Erro ao atualizar coordenada: ${erro.toString()}';
        notifyListeners();
      },
    );
  }

  void pararMonitoramento() {
    _fluxoCoordenadas?.cancel();
    _fluxoCoordenadas = null;
  }

  @override
  void dispose() {
    pararMonitoramento();
    super.dispose();
  }
}
