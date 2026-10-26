export interface CastExitGuard {
  update(active: boolean, stopCasting: () => void | Promise<void>): void;
  stopForExit(): Promise<boolean>;
}

export function createCastExitGuard(): CastExitGuard;
