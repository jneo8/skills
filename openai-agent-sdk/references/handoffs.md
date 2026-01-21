# Handoffs Guide

Build multi-agent systems with handoffs in the OpenAI Agents SDK.

## What are Handoffs?

Handoffs allow an agent to transfer control to another agent. This enables:
- Specialized agents for different domains
- Escalation workflows
- Language-specific routing
- Modular agent architectures

## Basic Handoff

```python
from agents import Agent, Runner

# Specialized agents
billing_agent = Agent(
    name="billing_agent",
    instructions="You handle billing inquiries. You can check balances, explain charges, and process refunds.",
)

technical_agent = Agent(
    name="technical_agent",
    instructions="You handle technical support. You troubleshoot issues and guide users through solutions.",
)

# Triage agent routes to specialists
triage_agent = Agent(
    name="triage_agent",
    instructions="""You are a customer service triage agent.

    Route customers to the appropriate specialist:
    - billing_agent: Payment issues, refunds, account charges
    - technical_agent: Product problems, bugs, how-to questions

    Always hand off to a specialist - don't try to handle issues yourself.""",
    handoffs=[billing_agent, technical_agent],
)

result = Runner.run_sync(triage_agent, "I was charged twice for my subscription")
print(result.final_output)
print(f"Handled by: {result.last_agent.name}")
```

## Handoff with Context

Agents share context during handoffs:

```python
from dataclasses import dataclass
from agents import Agent, Runner

@dataclass
class CustomerContext:
    customer_id: str
    subscription_tier: str

# Both agents have access to the same context
vip_agent = Agent[CustomerContext](
    name="vip_support",
    instructions="You provide premium support for VIP customers.",
)

standard_agent = Agent[CustomerContext](
    name="standard_support",
    instructions="You provide standard customer support.",
)

router = Agent[CustomerContext](
    name="router",
    instructions="""Route based on subscription tier:
    - premium/enterprise -> vip_support
    - free/basic -> standard_support""",
    handoffs=[vip_agent, standard_agent],
)

ctx = CustomerContext(customer_id="123", subscription_tier="premium")
result = Runner.run_sync(router, "I need help", context=ctx)
```

## Customizing Handoffs

Use `handoff()` for fine-grained control:

```python
from agents import Agent, handoff

refund_agent = Agent(
    name="refund_specialist",
    instructions="You process refund requests.",
)

support_agent = Agent(
    name="support",
    instructions="You handle general support.",
    handoffs=[
        handoff(
            agent=refund_agent,
            tool_name="transfer_to_refunds",
            tool_description="Transfer to refund specialist for refund requests over $100",
        ),
    ],
)
```

## Dynamic Handoffs

Generate handoffs at runtime:

```python
from agents import Agent, Runner, handoff

def get_available_agents() -> list[Agent]:
    """Get currently available specialist agents."""
    # Could query a database or service registry
    return [
        Agent(name="agent_a", instructions="Handle type A"),
        Agent(name="agent_b", instructions="Handle type B"),
    ]

router = Agent(
    name="dynamic_router",
    instructions="Route to the appropriate specialist.",
    handoffs=get_available_agents(),  # Called when agent is used
)
```

## Handoff Patterns

### Hub and Spoke

Central router with specialized spokes:

```python
# Spoke agents
sales = Agent(name="sales", instructions="Handle sales inquiries.")
support = Agent(name="support", instructions="Handle support requests.")
hr = Agent(name="hr", instructions="Handle HR questions.")

# Hub router
receptionist = Agent(
    name="receptionist",
    instructions="Welcome users and route to the right department.",
    handoffs=[sales, support, hr],
)
```

### Chain of Responsibility

Sequential escalation:

```python
tier3 = Agent(
    name="tier3",
    instructions="Expert support. Resolve the most complex issues.",
)

tier2 = Agent(
    name="tier2",
    instructions="Advanced support. Escalate to tier3 if unable to resolve.",
    handoffs=[tier3],
)

tier1 = Agent(
    name="tier1",
    instructions="Basic support. Escalate to tier2 for complex issues.",
    handoffs=[tier2],
)
```

### Bidirectional Handoffs

Agents can hand back:

```python
human_agent = Agent(name="human", instructions="A human operator.")
bot_agent = Agent(name="bot", instructions="An automated assistant.")

# Add cross-references after creation
human_agent = Agent(
    name="human",
    instructions="Human operator. Transfer routine queries to bot.",
    handoffs=[bot_agent],
)

bot_agent = Agent(
    name="bot",
    instructions="Automated assistant. Escalate to human when stuck.",
    handoffs=[human_agent],
)
```

### Language Routing

Route by detected language:

```python
english_agent = Agent(
    name="english_support",
    instructions="You provide support in English only.",
)

spanish_agent = Agent(
    name="spanish_support",
    instructions="Proporcionas soporte solo en español.",
)

french_agent = Agent(
    name="french_support",
    instructions="Vous fournissez une assistance uniquement en français.",
)

language_router = Agent(
    name="language_router",
    instructions="""Detect the user's language and route appropriately:
    - English -> english_support
    - Spanish -> spanish_support
    - French -> french_support

    If unsure, ask the user their preferred language.""",
    handoffs=[english_agent, spanish_agent, french_agent],
)
```

## Handoff Events in Streaming

Track handoffs in real-time:

```python
import asyncio
from agents import Agent, Runner
from agents.events import HandoffEvent

agent_a = Agent(name="agent_a", instructions="...")
agent_b = Agent(name="agent_b", instructions="...", handoffs=[agent_a])

async def track_handoffs():
    async for event in Runner.run_streamed(agent_b, "Hello"):
        if isinstance(event, HandoffEvent):
            print(f"Handoff: {event.from_agent} -> {event.to_agent}")

asyncio.run(track_handoffs())
```

## Best Practices

1. **Clear Routing Instructions**: Tell the router exactly when to handoff
2. **Specialist Focus**: Each agent should have a narrow, well-defined role
3. **Avoid Cycles**: Be careful with bidirectional handoffs to prevent loops
4. **Context Continuity**: Ensure important context flows through handoffs
5. **Max Turns Limit**: Set `max_turns` to prevent infinite handoff loops
6. **Logging**: Track handoffs for debugging and analytics

```python
result = Runner.run_sync(
    triage_agent,
    "Help me",
    max_turns=10,  # Prevent infinite loops
)

# Check handoff chain
for item in result.new_items:
    print(f"Agent: {item.agent.name if hasattr(item, 'agent') else 'N/A'}")
```
