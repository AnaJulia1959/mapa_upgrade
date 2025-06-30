import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import '../viewmodels/coordenada_controle.dart';

class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaEstado();
}

class _TelaMapaEstado extends State<TelaMapa> {
  final TextEditingController _controladorBusca = TextEditingController();
  late final MapController _controladorMapa;
  LatLng? _ultimaPosicao;

  @override
  void initState() {
    super.initState();
    _controladorMapa = MapController();
  }

  @override
  void dispose() {
    _controladorBusca.dispose();
    super.dispose();
  }

  Future<void> _buscarEnderecoEMover(String endereco) async {
    if (endereco.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira um endereço')),
      );
      return;
    }

    try {
      List<Location> resultados = await locationFromAddress(endereco);
      if (!mounted) return;
      if (resultados.isNotEmpty) {
        final local = resultados.first;
        final destino = LatLng(local.latitude, local.longitude);
        _controladorMapa.move(destino, 16);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço não encontrado')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar endereço: ${e.toString()}')),
      );
    }
  }

  void _atualizarPosicaoMapa(LatLng novaPosicao) {
    if (_ultimaPosicao == null ||
        _ultimaPosicao!.latitude != novaPosicao.latitude ||
        _ultimaPosicao!.longitude != novaPosicao.longitude) {
      _ultimaPosicao = novaPosicao;
      _controladorMapa.move(novaPosicao, _controladorMapa.camera.zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CoordenadaControle>(
      builder: (context, controle, child) {
        if (controle.carregando) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando coordenadas...'),
              ],
            ),
          );
        }

        if (controle.possuiErro) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  controle.mensagemErro,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controle.buscarCoordenada(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final coordenadaAtual = controle.coordenadaAtual;

        if (coordenadaAtual == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Não foi possível obter a coordenada.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Verifique se o GPS está ativado e as permissões estão concedidas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controle.buscarCoordenada(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final posicaoAtual = LatLng(coordenadaAtual.latitude, coordenadaAtual.longitude);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _atualizarPosicaoMapa(posicaoAtual);
        });

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controladorBusca,
                decoration: InputDecoration(
                  hintText: 'Buscar endereço...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _buscarEnderecoEMover(_controladorBusca.text.trim()),
                  ),
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (valor) => _buscarEnderecoEMover(valor.trim()),
              ),
            ),
            Expanded(
              child: FlutterMap(
                mapController: _controladorMapa,
                options: MapOptions(
                  initialCenter: posicaoAtual,
                  initialZoom: 16,
                  keepAlive: true,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'br.edu.ifsul.flutter_mapa_personalizado',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: posicaoAtual,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
