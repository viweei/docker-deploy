# kokoro-TTS 语音

[huging face](https://huggingface.co/spaces/hexgrad/Kokoro-TTS)
[github](https://github.com/thewh1teagle/kokoro-onnx)

目前只开放了美式英文，用于练单词使用，语音包没有打包到 docker 中, 需要从 github 下载后挂载到镜像里.

## 本地启动

```sh
pip install -U kokoro-onnx soundfile Falsk
python main.py
```

## Docker 启动

```sh
docker run --rm \
-v ./tts:/app/tts \
-p 5000:5000 \
-e SECRETKEY=1234567 \
kokoro:0.0.1

```
