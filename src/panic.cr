# Halt execution, with a *cause*. This method never returns.
#
# The default implementation does not use *message*. To report *message*,
# users are encouraged to override this method.
def panic(cause : String) : NoReturn
  loop { }
end
