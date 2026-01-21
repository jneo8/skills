# Quickstart Guide

This guide walks through setting up your first agent with the OpenAI Agents SDK.

## Prerequisites

- Python 3.9+
- OpenAI API key

## Installation

```bash
pip install openai-agents
```

Set your API key:

```bash
export OPENAI_API_KEY="your-api-key"
```

Or in Python:

```python
import os
os.environ["OPENAI_API_KEY"] = "your-api-key"
```

## Your First Agent

```python
from agents import Agent, Runner

# Create a simple agent
agent = Agent(
    name="my_assistant",
    instructions="You are a helpful assistant that provides concise answers.",
)

# Run synchronously
result = Runner.run_sync(agent, "What is the capital of France?")
print(result.final_output)
```

## Async Usage (Recommended)

```python
import asyncio
from agents import Agent, Runner

agent = Agent(
    name="async_assistant",
    instructions="You are a helpful assistant.",
)

async def main():
    result = await Runner.run(agent, "Tell me a joke")
    print(result.final_output)

asyncio.run(main())
```

## Adding a Tool

```python
from agents import Agent, Runner, function_tool

@function_tool
def calculate(expression: str) -> str:
    """Evaluate a mathematical expression."""
    try:
        result = eval(expression)
        return str(result)
    except Exception as e:
        return f"Error: {e}"

agent = Agent(
    name="calculator",
    instructions="You are a calculator assistant. Use the calculate tool for math.",
    tools=[calculate],
)

result = Runner.run_sync(agent, "What is 25 * 17 + 89?")
print(result.final_output)
```

## Streaming Responses

```python
import asyncio
from agents import Agent, Runner

agent = Agent(
    name="streaming_assistant",
    instructions="You are a helpful assistant.",
)

async def main():
    async for event in Runner.run_streamed(agent, "Write a haiku about coding"):
        if hasattr(event, 'delta'):
            print(event.delta, end='', flush=True)

asyncio.run(main())
```

## Using Context

Pass runtime data to your agent using context:

```python
from agents import Agent, Runner, RunContextWrapper, function_tool
from dataclasses import dataclass

@dataclass
class UserContext:
    user_id: str
    user_name: str

@function_tool
def get_user_info(wrapper: RunContextWrapper[UserContext]) -> str:
    """Get information about the current user."""
    ctx = wrapper.context
    return f"User: {ctx.user_name} (ID: {ctx.user_id})"

agent = Agent(
    name="personalized_assistant",
    instructions="You are a personalized assistant.",
    tools=[get_user_info],
)

context = UserContext(user_id="123", user_name="Alice")
result = Runner.run_sync(agent, "Who am I?", context=context)
print(result.final_output)
```

## Choosing a Model

```python
agent = Agent(
    name="gpt4_assistant",
    instructions="You are a helpful assistant.",
    model="gpt-4o",  # or "gpt-4o-mini", "gpt-4-turbo", etc.
)
```

## Next Steps

- Learn about [agent configuration](agents.md)
- Explore [tool patterns](tools.md)
- Build [multi-agent systems](handoffs.md)
- Add [safety guardrails](guardrails.md)
