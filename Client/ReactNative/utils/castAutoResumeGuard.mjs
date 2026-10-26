export function createCastAutoResumeGuard() {
  let suppressAutoResume = false;

  return {
    suppressUntilUserIntent() {
      suppressAutoResume = true;
    },

    allowUserIntent() {
      suppressAutoResume = false;
    },

    normalizeActive(active) {
      return active && !suppressAutoResume;
    },

    isSuppressed() {
      return suppressAutoResume;
    },
  };
}

export const androidAutoResumeGuard = createCastAutoResumeGuard();
