import 'package:itq_utils/src/emergent/shape/emergent_rrect_path_provider.dart';
import 'package:itq_utils/itq_utils.dart';

class StadiumPathProvider extends RRectPathProvider {
  const StadiumPathProvider({Listenable? reclip})
      : super(
            const BorderRadius.all(
              Radius.circular(1000),
            ),
            reclip: reclip);
}
