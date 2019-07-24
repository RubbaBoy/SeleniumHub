import 'package:uuid/uuid.dart';

void main() {
  var uuid = Uuid();
  var thisUuid = uuid.v5(Uuid.NAMESPACE_URL, 'uddernetworks.com');
  print('Uuid = $thisUuid');
}