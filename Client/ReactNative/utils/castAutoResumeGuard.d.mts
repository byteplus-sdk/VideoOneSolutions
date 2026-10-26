export interface CastAutoResumeGuard {
  suppressUntilUserIntent(): void;
  allowUserIntent(): void;
  normalizeActive(active: boolean): boolean;
  isSuppressed(): boolean;
}

export function createCastAutoResumeGuard(): CastAutoResumeGuard;
export const androidAutoResumeGuard: CastAutoResumeGuard;
