export function createCastExitGuard() {
  let active = false;
  let stoppedForCurrentSession = false;
  let stopCasting = () => {};

  return {
    update(nextActive, nextStopCasting) {
      if (!nextActive || !active) {
        stoppedForCurrentSession = false;
      }
      active = nextActive;
      stopCasting = nextStopCasting;
    },

    async stopForExit() {
      if (!active || stoppedForCurrentSession) {
        return false;
      }

      stoppedForCurrentSession = true;
      await stopCasting();
      return true;
    },
  };
}
