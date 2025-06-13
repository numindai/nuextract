# NuExtract


<p align="center">
    <img src="https://cdn.prod.website-files.com/638364a4e52e440048a9529c/64188f405afcf42d0b85b926_logo_numind_final.png" width="200"/>
<p>

<p align="center">
        🖥️ <a href="https://nuextract.ai/">API / Platform</a>&nbsp&nbsp | &nbsp&nbsp🤗 <a href="https://huggingface.co/numind">Hugging Face</a>&nbsp&nbsp | &nbsp&nbsp📚 <a href="https://github.com/numindai/nuextract/tree/main/cookbooks">Cookbooks</a>
<br>
🧑‍💻 <a href="https://numind.ai">Website</a>&nbsp&nbsp | &nbsp&nbsp📑 <a href="https://numind.ai/blog">Blog</a>&nbsp&nbsp | &nbsp&nbsp🗣️ <a href="https://discord.gg/3tsEtJNCDe">Discord</a>
</p>

<hr>

NuExtract 2.0 is a family of models trained specifically for structured information extraction tasks. It supports both multimodal inputs and is multilingual.

We provide several versions of different sizes, all based on pre-trained models from the QwenVL family.
| Model Size | Model Name | Base Model | License | Huggingface Link |
|------------|------------|------------|---------|------------------|
| 2B | NuExtract-2.0-2B | [Qwen2-VL-2B-Instruct](https://huggingface.co/Qwen/Qwen2-VL-2B-Instruct) | MIT | 🤗 [NuExtract-2.0-2B](https://huggingface.co/numind/NuExtract-2.0-2B) |
| 4B | NuExtract-2.0-4B | [Qwen2.5-VL-3B-Instruct](https://huggingface.co/Qwen/Qwen2.5-VL-3B-Instruct) | Qwen Research License | 🤗 [NuExtract-2.0-4B](https://huggingface.co/numind/NuExtract-2.0-4B) |
| 8B | NuExtract-2.0-8B | [Qwen2.5-VL-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct) | MIT | 🤗 [NuExtract-2.0-8B](https://huggingface.co/numind/NuExtract-2.0-8B) |

❗️Note: `NuExtract-2.0-2B` is based on Qwen2-VL rather than Qwen2.5-VL because the smallest Qwen2.5-VL model (3B) has a more restrictive, non-commercial license. We therefore include `NuExtract-2.0-2B` as a small model option that can still be used commercially.


## Overview

To use the model, provide an input text/image and a JSON template describing the information you need to extract. The template should be a JSON object, specifying field names and their expected type.

Supported types include:
* `verbatim-string` - instructs the model to extract text that is present verbatim in the input.
* `string` - a generic string field that can incorporate paraphrasing/abstraction.
* `integer` - a whole number.
* `number` - a whole or decimal number.
* `date-time` - ISO formatted date.
* Array of any of the above types (e.g. `["string"]`)
* `enum` - a choice from set of possible answers (represented in template as an array of options, e.g. `["yes", "no", "maybe"]`).
* `multi-label` - an enum that can have multiple possible answers (represented in template as a double-wrapped array, e.g. `[["A", "B", "C"]]`).

If the model does not identify relevant information for a field, it will return `null` or `[]` (for arrays and multi-labels).

The following is an example template:
```json
{
  "first_name": "verbatim-string",
  "last_name": "verbatim-string",
  "description": "string",
  "age": "integer",
  "gpa": "number",
  "birth_date": "date-time",
  "nationality": ["France", "England", "Japan", "USA", "China"],
  "languages_spoken": [["English", "French", "Japanese", "Mandarin", "Spanish"]]
}
```
An example output:
```json
{
  "first_name": "Susan",
  "last_name": "Smith",
  "description": "A student studying computer science.",
  "age": 20,
  "gpa": 3.7,
  "birth_date": "2005-03-01",
  "nationality": "England",
  "languages_spoken": ["English", "French"]
}
```
NuExtract can also support templates with nested attributes. E.g.
```json
{
  "employees": [
    {
      "name": "verbatim-string",
      "age": "integer",
      "occupation": {
        "industry": "string",
        "position_title": "verbatim-string"
      }
    }
  ],
  "companies": [
    {
      "name": "verbatim-string",
      "valuation": "number"
    }
  ]
}
```

## Usage
You can find an inference tutorial notebook in the [cookbooks](https://github.com/numindai/nuextract/tree/main/cookbooks) folder. Alternatively, see the individual model cards on Hugging Face for detailed instructions.

## Fine-Tuning
You can find a fine-tuning tutorial notebook in the [cookbooks](https://github.com/numindai/nuextract/tree/main/cookbooks) folder.

## vLLM Deployment
Run the command below to serve an OpenAI-compatible API:
```bash
vllm serve numind/NuExtract-2.0-8B --trust_remote_code --limit-mm-per-prompt image=6 --chat-template-content-format openai
```
If you encounter memory issues, set `--max-model-len` accordingly.

Send requests to the model as follows:
```python
import json
from openai import OpenAI

openai_api_key = "EMPTY"
openai_api_base = "http://localhost:8000/v1"

client = OpenAI(
    api_key=openai_api_key,
    base_url=openai_api_base,
)

chat_response = client.chat.completions.create(
    model="numind/NuExtract-2.0-8B",
    temperature=0,
    messages=[
        {
            "role": "user", 
            "content": [{"type": "text", "text": "Yesterday I went shopping at Bunnings"}],
        },
    ],
    extra_body={
        "chat_template_kwargs": {
            "template": json.dumps(json.loads("""{\"store\": \"verbatim-string\"}"""), indent=4)
        },
    }
)
print("Chat response:", chat_response)
```
For image inputs, structure requests as shown below. Make sure to order the images in `"content"` as they appear in the prompt (i.e. any in-context examples before the main input).
```python
import base64

def encode_image(image_path):
    """
    Encode the image file to base64 string
    """
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

base64_image = encode_image("0.jpg")
base64_image2 = encode_image("1.jpg")

chat_response = client.chat.completions.create(
    model="numind/NuExtract-2.0-8B",
    temperature=0,
    messages=[
        {
            "role": "user", 
            "content": [
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"}}, # first ICL example image
                {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{base64_image2}"}}, # real input image
            ],
        },
    ],
    extra_body={
        "chat_template_kwargs": {
            "template": json.dumps(json.loads("""{\"store\": \"verbatim-string\"}"""), indent=4),
            "examples": [
                {
                    "input": "<image>",
                    "output": """{\"store\": \"Walmart\"}"""
                }
            ]
        },
    }
)
print("Chat response:", chat_response)
```
