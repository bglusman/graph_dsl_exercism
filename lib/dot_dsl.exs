defmodule Graph do
  require IEx
  defstruct attrs: [], nodes: [], edges: []
end

defmodule Dot do
  @nodes ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z)a
  require IEx
  for node <- @nodes do
    defmacro unquote(node)(attrs) do
      node = unquote(node)
      quote do: node(unquote(node), unquote(attrs))
    end
    defmacro unquote(node)() do
      node = unquote(node)
      quote do: node(unquote(node), [])
    end
  end

  defmacro node(name, node_attrs) do
    quote do
      put_node(var!(buffer, Dot), [{unquote(name), unquote(node_attrs)}])
    end
  end

  defmacro edge1 -- edge2 do
    # if is_nil(edge1) || is_nil(edge2), do: raise ArgumentError
    quote do
      put_edge(var!(buffer, Dot), [{unquote(elem(edge1,0)), unquote(elem(edge2, 0)), []}])
    end
  end

  def start_buffer(state), do: Agent.start_link(fn -> state end)
  def stop_buffer(buff), do: Agent.stop(buff)
  def put_node(buff, content), do: Agent.update(buff, &(put_in &1.nodes, content)) 
  def put_edge(buff, content), do: Agent.update(buff, &(put_in &1.edges, content))
  def put_attr(buff, content), do: Agent.update(buff, &(put_in &1.attrs, content)) 

  defmacro graph(do: ast) do
    quote do
      import Dot
      import Kernel, except: [{:--, 2}]
      {:ok, var!(buffer, Dot)} = start_buffer(%Graph{})
      #unquote(ast)
      Code.eval_quoted(unquote(ast), [], __ENV__)
      graph_output = Agent.get(var!(buffer, Dot), &(&1))
      :ok = stop_buffer(var!(buffer, Dot))
      graph_output
    end
  end
end
