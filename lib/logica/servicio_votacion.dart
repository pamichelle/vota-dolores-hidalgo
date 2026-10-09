
import '../modelos/votacion.dart';
import '../modelos/opcion_votacion.dart';
import '../modelos/resultado_opcion.dart';
import 'resultado_voto.dart';

class ServicioVotacion {
  final Votacion votacion;

  ServicioVotacion(this.votacion);

  ResultadoVoto registrarVoto({
    required String idUsuario,
    required String idOpcion,
  }) {
    final yaCerro = DateTime.now().isAfter(votacion.fechaCierre);

    if (yaCerro) {
      return ResultadoVoto.votacionCerrada;
    }

    final yaVoto = votacion.votantes.contains(idUsuario);

    if (yaVoto) {
      return ResultadoVoto.usuarioYaVoto;
    }

    final opcion = _buscarOpcion(idOpcion);

    if (opcion == null) {
      return ResultadoVoto.opcionInvalida;
    }

    opcion.votos++;
    votacion.votantes.add(idUsuario);

    return ResultadoVoto.exitoso;
  }

  OpcionVotacion? _buscarOpcion(String id) {
    for (final opcion in votacion.opciones) {
      if (opcion.id == id) {
        return opcion;
      }
    }

    return null;
  }

  List<ResultadoOpcion> obtenerResultados() {
    int totalVotos = 0;

    for (final opcion in votacion.opciones) {
      totalVotos += opcion.votos;
    }

    final List<ResultadoOpcion> resultados = [];

    for (final opcion in votacion.opciones) {
      double porcentaje = 0;

      if (totalVotos > 0) {
        porcentaje = (opcion.votos / totalVotos) * 100;
      }

      resultados.add(
        ResultadoOpcion(opcion, porcentaje),
      );
    }

    return resultados;
  }

  List<OpcionVotacion> determinarGanador() {
    final maxVotos = votacion.opciones
        .map((opcion) => opcion.votos)
        .reduce((a, b) => a > b ? a : b);

    return votacion.opciones
        .where((opcion) => opcion.votos == maxVotos)
        .toList();
  }
}

