# NuExtract


<p align="center">
    <img src="https://cdn.prod.website-files.com/638364a4e52e440048a9529c/64188f405afcf42d0b85b926_logo_numind_final.png" width="200"/>
<p>

<p align="center">
        🧑‍💻 <a href="https://numind.ai"><b>Website</b></a>&nbsp&nbsp | &nbsp&nbsp🤗 <a href="https://huggingface.co/numind">Hugging Face</a>&nbsp&nbsp | &nbsp&nbsp📑 <a href="https://numind.ai/blog">Blog</a>&nbsp&nbsp | &nbsp&nbsp📚 <a href="https://github.com/numindai/nuextract/tree/main/cookbooks">Cookbooks</a>
<br>
🖥️ <a href="https://huggingface.co/spaces/numind/">Demo</a>&nbsp&nbsp | &nbsp&nbsp🗣️ <a href="https://discord.com/3tsEtJNCDe">Discord</a>
</p>

<hr>

NuExtract 2.0 is a family of models trained specifically for structured information extraction tasks. It supports both multimodal inputs and is multilingual.

We provide several versions of different sizes, all based on pre-trained models from the QwenVL family.
| Model Size | Model Name | Base Model | Huggingface Link |
|------------|------------|------------|------------------|
| 2B | NuExtract-2.0-2B | [Qwen2-VL-2B-Instruct](https://huggingface.co/Qwen/Qwen2-VL-2B-Instruct) | 🤗 [NuExtract-2.0-2B](https://huggingface.co/numind/NuExtract-2.0-2B) |
| 8B | NuExtract-2.0-8B | [Qwen2.5-VL-7B-Instruct](https://huggingface.co/Qwen/Qwen2.5-VL-7B-Instruct) | 🤗 [NuExtract-2.0-8B](https://huggingface.co/numind/NuExtract-2.0-8B) |

❗️Note: `NuExtract-2.0-2B` is based on Qwen2-VL rather than Qwen2.5-VL because the smallest Qwen2.5-VL model (3B) has a more restrictive licence.

## Overview

To use the model, provide an input text/image and a JSON template describing the information you need to extract. The template should be a JSON object, specifying field names and their expected type.

Support types include:
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