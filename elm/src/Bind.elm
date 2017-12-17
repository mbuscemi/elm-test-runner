module Bind exposing (arity0, arity1, arity2)


arity0 : (secondaryMessage -> primaryMessage) -> secondaryMessage -> primaryMessage
arity0 messageWrapper secondaryMessage =
    messageWrapper secondaryMessage


arity1 : (secondaryMessage -> primaryMessage) -> (a -> secondaryMessage) -> a -> primaryMessage
arity1 messageWrapper secondaryMessage =
    messageWrapper << secondaryMessage


arity2 : (secondaryMessage -> primaryMessage) -> (a -> b -> secondaryMessage) -> a -> b -> primaryMessage
arity2 messageWrapper secondaryMessage a b =
    messageWrapper <| secondaryMessage a b
