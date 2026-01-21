# Tools Reference

Complete guide to defining and using tools with the OpenAI Agents SDK.

## Function Tools

The most common way to create tools is with the `@function_tool` decorator:

```python
from agents import function_tool

@function_tool
def search_database(query: str, limit: int = 10) -> str:
    """Search the database for matching records.

    Args:
        query: The search query string
        limit: Maximum number of results to return
    """
    # Implementation
    results = db.search(query, limit=limit)
    return json.dumps(results)
```

### Type Annotations

Tools use type annotations for parameter schemas:

```python
from typing import Literal
from agents import function_tool

@function_tool
def create_task(
    title: str,
    priority: Literal["low", "medium", "high"],
    tags: list[str] | None = None,
) -> str:
    """Create a new task.

    Args:
        title: Task title
        priority: Task priority level
        tags: Optional list of tags
    """
    return f"Created task: {title}"
```

### Pydantic Models for Complex Types

```python
from pydantic import BaseModel, Field
from agents import function_tool

class OrderDetails(BaseModel):
    product_id: str = Field(description="Product identifier")
    quantity: int = Field(ge=1, description="Quantity to order")
    shipping_address: str = Field(description="Delivery address")

@function_tool
def place_order(order: OrderDetails) -> str:
    """Place a new order."""
    return f"Order placed for {order.quantity}x {order.product_id}"
```

## Accessing Context in Tools

Tools can access the run context:

```python
from agents import function_tool, RunContextWrapper
from dataclasses import dataclass

@dataclass
class UserContext:
    user_id: str
    api_key: str

@function_tool
def get_user_data(wrapper: RunContextWrapper[UserContext]) -> str:
    """Get data for the current user."""
    user_id = wrapper.context.user_id
    api_key = wrapper.context.api_key
    # Use context to make authenticated request
    return fetch_user_data(user_id, api_key)
```

## Async Tools

Tools can be async for I/O operations:

```python
import httpx
from agents import function_tool

@function_tool
async def fetch_url(url: str) -> str:
    """Fetch content from a URL."""
    async with httpx.AsyncClient() as client:
        response = await client.get(url)
        return response.text[:1000]  # Truncate for safety
```

## Tool Configuration

Customize tool behavior:

```python
from agents import function_tool

@function_tool(
    name_override="search",           # Custom tool name
    description_override="Search the web",  # Custom description
    strict_mode=True,                 # Strict JSON schema validation
)
def web_search(query: str) -> str:
    """Original docstring (overridden by description_override)."""
    return search_web(query)
```

## Hosted Tools (OpenAI Built-ins)

Use OpenAI's hosted tools:

```python
from agents import Agent
from agents.tools import WebSearchTool, FileSearchTool, CodeInterpreterTool

agent = Agent(
    name="research_assistant",
    instructions="You help with research tasks.",
    tools=[
        WebSearchTool(),              # Web search capability
        FileSearchTool(               # Search uploaded files
            vector_store_ids=["vs_123"],
        ),
        CodeInterpreterTool(),        # Execute Python code
    ],
)
```

## Tool Patterns

### Multiple Related Tools

Group related tools logically:

```python
from agents import function_tool

@function_tool
def list_files(directory: str) -> str:
    """List files in a directory."""
    ...

@function_tool
def read_file(path: str) -> str:
    """Read file contents."""
    ...

@function_tool
def write_file(path: str, content: str) -> str:
    """Write content to a file."""
    ...

file_tools = [list_files, read_file, write_file]

agent = Agent(
    name="file_manager",
    instructions="You help manage files.",
    tools=file_tools,
)
```

### Tools with Side Effects

Handle tools that modify state:

```python
from agents import function_tool, RunContextWrapper
from dataclasses import dataclass, field

@dataclass
class SessionState:
    cart: list = field(default_factory=list)

@function_tool
def add_to_cart(
    wrapper: RunContextWrapper[SessionState],
    product_id: str,
    quantity: int = 1,
) -> str:
    """Add a product to the shopping cart."""
    wrapper.context.cart.append({
        "product_id": product_id,
        "quantity": quantity,
    })
    return f"Added {quantity}x {product_id} to cart"

@function_tool
def view_cart(wrapper: RunContextWrapper[SessionState]) -> str:
    """View current cart contents."""
    if not wrapper.context.cart:
        return "Cart is empty"
    return json.dumps(wrapper.context.cart)
```

### Error Handling in Tools

Return informative errors:

```python
from agents import function_tool

@function_tool
def divide(a: float, b: float) -> str:
    """Divide two numbers."""
    if b == 0:
        return "Error: Cannot divide by zero"
    return str(a / b)

@function_tool
def fetch_order(order_id: str) -> str:
    """Fetch order details by ID."""
    try:
        order = db.get_order(order_id)
        if order is None:
            return f"Error: Order {order_id} not found"
        return json.dumps(order)
    except Exception as e:
        return f"Error fetching order: {str(e)}"
```

### Parallel Tool Execution

Mark tools as safe for parallel execution:

```python
from agents import Agent, function_tool

@function_tool
def get_weather(city: str) -> str:
    """Get weather for a city."""
    ...

@function_tool
def get_news(topic: str) -> str:
    """Get news about a topic."""
    ...

# These tools can run in parallel when both are called
agent = Agent(
    name="info_gatherer",
    instructions="You gather information from multiple sources.",
    tools=[get_weather, get_news],
    parallel_tool_calls=True,  # Enable parallel execution
)
```

## Tool Best Practices

1. **Clear Docstrings**: The docstring becomes the tool description
2. **Type Hints**: Always use type annotations
3. **Return Strings**: Tools should return string results
4. **Handle Errors**: Return error messages rather than raising exceptions
5. **Limit Output Size**: Truncate large responses
6. **Idempotency**: Make read operations idempotent when possible
7. **Validation**: Validate inputs early in the function
