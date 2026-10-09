
import 'package:flutter_test/flutter_test.dart';
import 'package:vota_dolores_hidalgo/modelos/opcion_votacion.dart';
import 'package:vota_dolores_hidalgo/modelos/votacion.dart';
import 'package:vota_dolores_hidalgo/logica/resultado_voto.dart';
import 'package:vota_dolores_hidalgo/logica/servicio_votacion.dart';

Votacion _crearVotacionDePrueba({DateTime? fechaCierre}) {
  return Votacion(
    pregunta: 'Pregunta de prueba',
    opciones: [
      OpcionVotacion(id: 'op1', texto: 'Opcion 1'),
      OpcionVotacion(id: 'op2', texto: 'Opcion 2'),
    ],
    fechaCierre:
        fechaCierre ?? DateTime.now().add(const Duration(days: 7)),
  );
}

void main() {
  test('registrar un voto valido incrementa el contador', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final resultado = servicio.registrarVoto(
      idUsuario: 'user1',
      idOpcion: 'op1',
    );

    expect(resultado, ResultadoVoto.exitoso);
    expect(votacion.opciones[0].votos, 1);
  });

  test('una opcion inexistente devuelve opcionInvalida', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final resultado = servicio.registrarVoto(
      idUsuario: 'user2',
      idOpcion: 'op999',
    );

    expect(resultado, ResultadoVoto.opcionInvalida);
  });

  test('un usuario no puede votar dos veces', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final primerVoto = servicio.registrarVoto(
      idUsuario: 'user1',
      idOpcion: 'op1',
    );

    final segundoVoto = servicio.registrarVoto(
      idUsuario: 'user1',
      idOpcion: 'op2',
    );

    expect(primerVoto, ResultadoVoto.exitoso);
    expect(segundoVoto, ResultadoVoto.usuarioYaVoto);
    expect(votacion.opciones[0].votos, 1);
    expect(votacion.opciones[1].votos, 0);
  });

  test('calcula correctamente los porcentajes de los votos', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    votacion.opciones[0].votos = 3;
    votacion.opciones[1].votos = 2;

    final resultados = servicio.obtenerResultados();

    expect(resultados[0].porcentaje, 60.0);
    expect(resultados[1].porcentaje, 40.0);
  });

  test('si no hay votos, los porcentajes son cero', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    final resultados = servicio.obtenerResultados();

    expect(resultados[0].porcentaje, 0.0);
    expect(resultados[1].porcentaje, 0.0);
  });

  test('determinarGanador regresa la opcion con mas votos', () {
    final votacion = _crearVotacionDePrueba();
    final servicio = ServicioVotacion(votacion);

    servicio.registrarVoto(
      idUsuario: 'u1',
      idOpcion: 'op1',
    );

    servicio.registrarVoto(
      idUsuario: 'u2',
      idOpcion: 'op1',
    );

    servicio.registrarVoto(
      idUsuario: 'u3',
      idOpcion: 'op2',
    );

    final ganadores = servicio.determinarGanador();

    expect(ganadores.length, 1);
    expect(ganadores.first.id, 'op1');
  });

  test('si varias opciones tienen los mismos votos, hay empate', () {
    final votacion = _crearVotacionDePrueba();

    votacion.opciones.add(
      OpcionVotacion(id: 'op3', texto: 'Opcion 3'),
    );

    final servicio = ServicioVotacion(votacion);

    servicio.registrarVoto(
      idUsuario: 'user1',
      idOpcion: 'op1',
    );

    servicio.registrarVoto(
      idUsuario: 'user2',
      idOpcion: 'op2',
    );

    servicio.registrarVoto(
      idUsuario: 'user3',
      idOpcion: 'op3',
    );

    final ganadores = servicio.determinarGanador();

    expect(ganadores.length, 3);
  });
}

