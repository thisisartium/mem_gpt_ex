defmodule MemGpt.UserMessage do
  use TypedStruct

  typedstruct do
    field(:content, String.t())
  end
end
