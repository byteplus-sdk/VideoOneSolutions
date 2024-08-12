import type {VeLivePusher} from '@byteplus/react-native-live-push';
import {getPusher} from '../pusher';
import {ensureFile, toAbsFilepath, type ReadStream} from './fs';

export interface ExternalSourceConfig {
  filename: string;
  url: string;
}

export abstract class ExternalSource<Frame> {
  private _timer?: ReturnType<typeof setTimeout>;
  private _task: () => void;
  protected _fps: number;
  protected _stream!: ReadStream;
  protected _filepath!: string;

  constructor(public config: ExternalSourceConfig) {
    this._fps = 30;
    this._task = async () => {
      try {
        await this._run();
      } catch (err) {
        console.warn('ExternalSource push frame fail', err);
      }
      this._next();
    };
  }

  async start() {
    try {
      const absFilepath = toAbsFilepath('/' + this.config.filename);
      this._filepath = absFilepath;
      await ensureFile(absFilepath, this.config.url);
      const stream = await this.buildStream(absFilepath);
      this._stream = stream;
      this._task();
    } catch (err) {
      console.error('ExternalSource start fail', err);
    }
  }

  stop() {
    if (this._timer) {
      clearTimeout(this._timer);
    }
  }

  protected _next() {
    this._timer = setTimeout(this._task, (1000 * 60) / this._fps);
  }

  protected async _run() {
    const data = await this._stream.readNext();
    const frame = await this.buildFrame(data);
    const p = getPusher();
    this.pushFrame(p, frame);
  }

  protected abstract buildStream(_filepath: string): Promise<ReadStream>;
  protected abstract buildFrame(_data: Uint8Array): Frame;
  protected abstract pushFrame(_pusher: VeLivePusher, _frame: Frame): void;
}
