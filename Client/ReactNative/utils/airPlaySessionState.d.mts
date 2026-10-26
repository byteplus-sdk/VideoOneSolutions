export const AirPlaySessionState: Readonly<{
  IDLE: 'idle';
  ROUTE_SELECTING: 'routeSelecting';
  ROUTE_SELECTED: 'routeSelected';
  STARTING: 'starting';
  CASTING: 'casting';
  STOPPING: 'stopping';
  FAILED: 'failed';
}>;

export type AirPlaySessionStateValue =
  (typeof AirPlaySessionState)[keyof typeof AirPlaySessionState];

export interface AirPlaySessionSnapshot {
  generation: number;
  state: AirPlaySessionStateValue;
  routeActive: boolean;
  externalPlaybackActive: boolean;
  isCasting: boolean;
  currentTime: number;
  shouldResumeLocal: boolean;
  errorCode?: string;
}

export type AirPlaySessionEvent =
  | {
      type: 'BEGIN_ROUTE_SELECTION';
    }
  | {
      type: 'ROUTE_CHANGED';
      routeActive: boolean;
      generation?: number;
      currentTime?: number;
    }
  | {
      type: 'START_RELAY';
      generation?: number;
    }
  | {
      type: 'EXTERNAL_PLAYBACK_READY';
      generation?: number;
      currentTime?: number;
    }
  | {
      type: 'START_FAILED';
      errorCode: string;
      generation?: number;
    }
  | {
      type: 'BEGIN_STOP';
      generation?: number;
    };

export function createAirPlaySessionSnapshot(): AirPlaySessionSnapshot;

export function reduceAirPlaySession(
  snapshot: AirPlaySessionSnapshot,
  event: AirPlaySessionEvent,
): AirPlaySessionSnapshot;

export function shouldBlockAirPlayExit(
  snapshot: AirPlaySessionSnapshot,
): boolean;
