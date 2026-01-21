---
name: openai-agent-sdk
description: Guide for building AI agents using the OpenAI Agents SDK (openai-agents). Use this skill when implementing agentic applications, multi-agent systems, tool-using agents, or workflows with handoffs and guardrails using OpenAI's official agent framework.
---

# OpenAI Agents SDK Guide

The OpenAI Agents SDK is a lightweight Python framework for building agentic AI applications. It provides primitives for creating agents with tools, orchestrating multi-agent handoffs, and implementing guardrails.

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Agent** | An LLM configured with instructions, tools, and handoffs |
| **Tool** | Functions the agent can call to perform actions |
| **Handoff** | Mechanism for transferring control between agents |
| **Guardrail** | Input/output validators that run in parallel with the agent |
| **Runner** | Execution engine that manages the agent loop |
| **Trace** | Built-in observability for debugging agent behavior |

## Installation

```bash
pip install openai-agents
```

## Basic Agent Example

```python
from agents import Agent, Runner

agent = Agent(
    name="assistant",
    instructions="You are a helpful assistant.",
)

result = Runner.run_sync(agent, "Hello, how can you help me?")
print(result.final_output)
```

## Agent with Tools

```python
from agents import Agent, Runner, function_tool

@function_tool
def get_weather(city: str) -> str:
    """Get the current weather for a city."""
    return f"The weather in {city} is sunny, 72°F"

agent = Agent(
    name="weather_assistant",
    instructions="You help users check the weather.",
    tools=[get_weather],
)

result = Runner.run_sync(agent, "What's the weather in Tokyo?")
```

## Multi-Agent Handoffs

```python
from agents import Agent, Runner

spanish_agent = Agent(
    name="spanish_agent",
    instructions="You only speak Spanish. Answer in Spanish.",
)

english_agent = Agent(
    name="english_agent",
    instructions="You only speak English. Answer in English.",
)

triage_agent = Agent(
    name="triage_agent",
    instructions="Determine the language and hand off to the appropriate agent.",
    handoffs=[spanish_agent, english_agent],
)

result = Runner.run_sync(triage_agent, "Hola, ¿cómo estás?")
```

## Key Principles

1. **Minimal Abstraction**: The SDK provides primitives, not opinionated frameworks
2. **Python-Native**: Tools are regular Python functions with type hints
3. **Async-First**: Built for async, with sync wrappers available
4. **Observable**: Built-in tracing for debugging and monitoring

## When to Use Each Pattern

| Pattern | Use Case |
|---------|----------|
| Single Agent + Tools | Simple task automation, Q&A with data access |
| Multi-Agent Handoffs | Specialized domains, language routing, escalation |
| Guardrails | Content moderation, PII filtering, format validation |
| Parallel Tools | Independent operations that can run concurrently |

## Reference Documentation

- [Quickstart Guide](references/quickstart.md) - Getting started with installation and first agent
- [Agents Deep Dive](references/agents.md) - Agent configuration, context, and lifecycle
- [Tools Reference](references/tools.md) - Function tools, hosted tools, and tool patterns
- [Handoffs Guide](references/handoffs.md) - Multi-agent orchestration and routing
- [Guardrails](references/guardrails.md) - Input/output validation and safety
