import notifee from '@notifee/react-native';

let displayId: string;

export const start = async () => {
  if (displayId) {
    return;
  }
  try {
    let channelId = await notifee.createChannel({
      id: 'default',
      name: 'Default Channel',
    });
    displayId = await notifee.displayNotification({
      title: 'VeLiveRnDemo running...',
      android: {
        channelId,
        asForegroundService: true,
      },
    });
  } catch (err) {
    console.error('Error starting foreground service:', err);
  }
};

export const stop = () => {
  if (!displayId) {
    return;
  }
  notifee.cancelDisplayedNotification(displayId);
  displayId = '';
};

/**
 * Toggles the background task
 */
let playing = false;
export const toggleBackground = async (isPlaying?: boolean) => {
  playing = isPlaying ?? !playing;
  if (playing) {
    try {
      console.log('Trying to start background service');
      await start();
      console.log('Successful start!');
    } catch (e) {
      console.log('Error', e);
    }
  } else {
    console.log('Stop background service');
    stop();
  }
};
