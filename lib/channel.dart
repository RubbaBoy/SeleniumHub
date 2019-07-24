import 'package:aqueduct/aqueduct.dart';

import 'todo.dart';

class AppChannel extends ApplicationChannel {
  @override
  Controller get entryPoint {
    final router = Router();
    router
        .route("/shit")
        .link(() => LoginAuthorizer())
        .linkFunction((req) async => Response.ok("Shit"));

    router
        .route("/users/[:id]")
        .link(() => LoginAuthorizer())
        .link(() => MyController());

    router.route("/login").linkFunction(
          (_) => Response.unauthorized(
              headers: {"WWW-Authenticate": "Basic"},
              body: "Authenticate"),
        );

    return router;
  }
}

class LoginAuthorizer extends Controller {
  @override
  FutureOr<RequestOrResponse> handle(Request request) async {
    try {
      RequestOrResponse reqOrResp = await Authorizer.basic(PasswordVerifier()).handle(request);
      if (reqOrResp is Response) return Response.unauthorized(headers: {"WWW-Authenticate": "Basic"});
      return reqOrResp;
    } catch (e) {
      return Response.serverError(body: e.toString());
    }
  }
}

class MyController extends ResourceController {
  final List<String> things = ['thing1', 'thing2'];

  @Operation.get()
  Future<Response> getThings() async {
    return Response.ok(things);
  }

  @Operation.get('id')
  Future<Response> getThing(@Bind.path('id') int id) async {
    if (id < 0 || id >= things.length) {
      return Response.notFound();
    }
    return Response.ok(things[id]);
  }
}

class PasswordVerifier extends AuthValidator {
  @override
  FutureOr<Authorization> validate<T>(
      AuthorizationParser<T> parser, T authorizationData,
      {List<AuthScope> requiredScope}) {
    final validUsername = 'rubba';
    final validPassword = 'pass';

    final credentials = authorizationData as AuthBasicCredentials;

    if (credentials.username == validUsername &&
        credentials.password == validPassword) {
      return Authorization(
          null, // no client ID for basic auth
          42069,
          this, // always this
          credentials: credentials // if you want to pass this info along
          );
    }

    return null;
  }
}
