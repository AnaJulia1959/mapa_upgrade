import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/coordenada_controle.dart';
import 'views/tela_mapa.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CoordenadaControle()..buscarCoordenada(),
      child: const AplicativoMapa(),
    ),
  );
}

class AplicativoMapa extends StatelessWidget {
  const AplicativoMapa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa OSM',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Visualização de Coordenada'),
        ),
        body: const TelaMapa(),
      ),
    );
  }
}
