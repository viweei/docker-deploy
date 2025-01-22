import io
import os
import soundfile as sf
from kokoro_onnx import Kokoro
from flask import Flask, send_file, request

app = Flask(__name__)
kokoro = Kokoro("tts/kokoro-v0_19.onnx", "tts/voices.npz")
available_voices = ['af_bella', 'af_nicole', 'af_sarah', 'af_sky',
                    'am_adam', 'am_michael', 'bf_emma', 'bf_isabella',
                    'bm_george', 'bm_lewis']

def speaker(text, voice, speed):
  samples, sample_rate = kokoro.create(
      text,
      voice=voice or 'am_michael',
      speed=speed,
      lang='en-us'
  )

  # 将音频数据写入内存中的字节流
  audio_buffer = io.BytesIO()
  sf.write(audio_buffer, samples, sample_rate, format='WAV')
  audio_buffer.seek(0)
  
  return audio_buffer
  

@app.route("/")
def speak():
    # 验证 secretkey
    if os.environ.get('SECRETKEY'):
      secret_key = request.headers.get('secretkey')
      if not secret_key or secret_key != os.environ.get('SECRETKEY'):
          return "secretkey 验证失败", 401

    text = request.args.get('text')
    if not text:
        return "缺少必要的text参数", 400

    voice = request.args.get('voice')
    if voice and voice not in available_voices:
        return "不支持的voice参数", 400

    speed = request.args.get('speed', 1.0, type=float)

    # 返回音频文件作为响应
    return send_file(
        speaker(text, voice, speed),
        mimetype="audio/wav",
        as_attachment=False,
        download_name="audio.wav"
    )


@app.route("/voices")
def get_voices():
    return {"voices": available_voices}


if __name__ == "__main__":
    app.run(debug=True)
