# Agents Deep Dive

Comprehensive guide to configuring and managing agents in the OpenAI Agents SDK.

## Agent Configuration

```python
from agents import Agent

agent = Agent(
    name="my_agent",                    # Required: unique identifier
    instructions="You are helpful.",    # System prompt
    model="gpt-4o",                     # Model to use
    tools=[],                           # List of tools
    handoffs=[],                        # Agents to hand off to
    model_settings=ModelSettings(       # Optional model settings
        temperature=0.7,
        max_tokens=1000,
    ),
)
```

## Dynamic Instructions

Instructions can be static strings or dynamic functions:

```python
from agents import Agent, RunContextWrapper

def dynamic_instructions(
    context: RunContextWrapper[MyContext],
    agent: Agent[MyContext]
) -> str:
    user = context.context.user_name
    return f"You are helping {user}. Be friendly and concise."

agent = Agent(
    name="dynamic_agent",
    instructions=dynamic_instructions,
)
```

## Agent Context

Context allows passing runtime data to agents and tools:

```python
from dataclasses import dataclass
from agents import Agent, Runner

@dataclass
class AppContext:
    user_id: str
    session_id: str
    permissions: list[str]

agent = Agent[AppContext](
    name="context_aware",
    instructions="You have access to user context.",
)

ctx = AppContext(
    user_id="user_123",
    session_id="sess_abc",
    permissions=["read", "write"]
)

result = Runner.run_sync(agent, "What can I do?", context=ctx)
```

## Model Settings

Fine-tune model behavior:

```python
from agents import Agent, ModelSettings

agent = Agent(
    name="precise_agent",
    instructions="You give precise, factual answers.",
    model_settings=ModelSettings(
        temperature=0.0,        # Deterministic output
        max_tokens=500,         # Limit response length
        top_p=1.0,              # Nucleus sampling
        frequency_penalty=0.0,  # Repetition control
        presence_penalty=0.0,   # Topic diversity
    ),
)
```

## Agent Lifecycle

The agent loop follows this pattern:

1. **Input Processing**: User message is processed
2. **LLM Call**: Agent generates a response
3. **Tool Execution**: If tools are called, execute them
4. **Handoff Check**: If handoff requested, transfer control
5. **Guardrail Validation**: Output guardrails run
6. **Response**: Final output returned or loop continues

```python
from agents import Agent, Runner

async def observe_lifecycle():
    agent = Agent(name="test", instructions="Be helpful.")

    async for event in Runner.run_streamed(agent, "Hello"):
        print(f"Event type: {type(event).__name__}")
```

## Run Result

The `RunResult` object contains execution details:

```python
result = Runner.run_sync(agent, "Hello")

# Access results
print(result.final_output)        # The final text response
print(result.last_agent)          # The agent that produced output
print(result.new_items)           # All items generated
print(result.input_guardrail_results)   # Input guardrail outcomes
print(result.output_guardrail_results)  # Output guardrail outcomes
```

## Conversation History

Maintain conversation state across runs:

```python
from agents import Agent, Runner

agent = Agent(name="stateful", instructions="Remember our conversation.")

# First turn
result1 = Runner.run_sync(agent, "My name is Alice.")

# Continue with history
result2 = Runner.run_sync(
    agent,
    "What is my name?",
    input=result1.to_input_list() + [{"role": "user", "content": "What is my name?"}]
)
```

## Cloning Agents

Create variations of an agent:

```python
base_agent = Agent(
    name="base",
    instructions="You are helpful.",
    tools=[search_tool],
)

# Clone with modifications
specialized_agent = base_agent.clone(
    name="specialized",
    instructions="You are a Python expert.",
)
```

## System Prompt Best Practices

1. **Be Specific**: Clear role and capabilities
2. **Set Boundaries**: What the agent should/shouldn't do
3. **Format Instructions**: How to structure responses
4. **Tool Guidance**: When to use which tools

```python
agent = Agent(
    name="well_instructed",
    instructions="""You are a customer support agent for Acme Corp.

Your responsibilities:
- Answer questions about our products
- Help with order status inquiries
- Escalate billing issues to the billing_agent

Guidelines:
- Be polite and professional
- Keep responses concise (under 100 words)
- Always verify order numbers before looking them up
- Never share customer PII

When you don't know something, say so honestly.""",
)
```

## Error Handling

Handle agent errors gracefully:

```python
from agents import Agent, Runner
from agents.exceptions import AgentError, MaxTurnsExceeded

agent = Agent(name="test", instructions="Be helpful.")

try:
    result = Runner.run_sync(
        agent,
        "Do something complex",
        max_turns=10,
    )
except MaxTurnsExceeded:
    print("Agent exceeded maximum turns")
except AgentError as e:
    print(f"Agent error: {e}")
```
