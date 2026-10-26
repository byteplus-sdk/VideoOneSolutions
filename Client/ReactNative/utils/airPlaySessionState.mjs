export const AirPlaySessionState = Object.freeze({
  IDLE: 'idle',
  ROUTE_SELECTING: 'routeSelecting',
  ROUTE_SELECTED: 'routeSelected',
  STARTING: 'starting',
  CASTING: 'casting',
  STOPPING: 'stopping',
  FAILED: 'failed',
});

export function createAirPlaySessionSnapshot() {
  return {
    generation: 0,
    state: AirPlaySessionState.IDLE,
    routeActive: false,
    externalPlaybackActive: false,
    isCasting: false,
    currentTime: 0,
    shouldResumeLocal: false,
  };
}

function latestCurrentTime(snapshot, event) {
  return event.currentTime ?? snapshot.currentTime;
}

export function reduceAirPlaySession(snapshot, event) {
  if (
    event.generation !== undefined &&
    event.generation !== snapshot.generation
  ) {
    return snapshot;
  }

  switch (event.type) {
    case 'BEGIN_ROUTE_SELECTION':
      return {
        ...snapshot,
        generation: snapshot.generation + 1,
        state: AirPlaySessionState.ROUTE_SELECTING,
        shouldResumeLocal: false,
      };
    case 'ROUTE_CHANGED':
      if (!event.routeActive) {
        return {
          ...createAirPlaySessionSnapshot(),
          generation: snapshot.generation,
          currentTime: latestCurrentTime(snapshot, event),
          shouldResumeLocal: [
            AirPlaySessionState.STARTING,
            AirPlaySessionState.CASTING,
            AirPlaySessionState.STOPPING,
          ].includes(snapshot.state),
        };
      }

      if (
        snapshot.state === AirPlaySessionState.IDLE ||
        snapshot.state === AirPlaySessionState.FAILED
      ) {
        return snapshot.routeActive
          ? snapshot
          : {
              ...snapshot,
              routeActive: true,
            };
      }

      return {
        ...snapshot,
        state:
          snapshot.state === AirPlaySessionState.ROUTE_SELECTING
            ? AirPlaySessionState.ROUTE_SELECTED
            : snapshot.state,
        routeActive: true,
        shouldResumeLocal: false,
      };
    case 'START_RELAY':
      if (snapshot.state !== AirPlaySessionState.ROUTE_SELECTED) {
        return snapshot;
      }

      return {
        ...snapshot,
        state: AirPlaySessionState.STARTING,
        externalPlaybackActive: false,
        isCasting: false,
        shouldResumeLocal: false,
      };
    case 'EXTERNAL_PLAYBACK_READY':
      if (snapshot.state !== AirPlaySessionState.STARTING) {
        return snapshot;
      }

      return {
        ...snapshot,
        state: AirPlaySessionState.CASTING,
        routeActive: true,
        externalPlaybackActive: true,
        isCasting: true,
        currentTime: latestCurrentTime(snapshot, event),
        shouldResumeLocal: false,
      };
    case 'START_FAILED':
      if (snapshot.state !== AirPlaySessionState.STARTING) {
        return snapshot;
      }

      return {
        ...snapshot,
        state: AirPlaySessionState.FAILED,
        externalPlaybackActive: false,
        isCasting: false,
        shouldResumeLocal: true,
        errorCode: event.errorCode,
      };
    case 'BEGIN_STOP':
      if (
        ![
          AirPlaySessionState.ROUTE_SELECTED,
          AirPlaySessionState.STARTING,
          AirPlaySessionState.CASTING,
        ].includes(snapshot.state)
      ) {
        return snapshot;
      }

      return {
        ...snapshot,
        state: AirPlaySessionState.STOPPING,
        isCasting: false,
      };
    default:
      return snapshot;
  }
}

export function shouldBlockAirPlayExit(snapshot) {
  return (
    snapshot.routeActive ||
    [
      AirPlaySessionState.ROUTE_SELECTING,
      AirPlaySessionState.ROUTE_SELECTED,
      AirPlaySessionState.STARTING,
      AirPlaySessionState.CASTING,
      AirPlaySessionState.STOPPING,
    ].includes(snapshot.state)
  );
}
