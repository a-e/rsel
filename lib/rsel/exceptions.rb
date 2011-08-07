module Rsel
  class LocatorNotFound < RuntimeError; end
  class StopTestCannotConnect < RuntimeError; end
  class StopTestSessionNotStarted < RuntimeError; end
  class StopTestStepFailed < RuntimeError; end
  class StopTestInputDisabled < RuntimeError; end
end
