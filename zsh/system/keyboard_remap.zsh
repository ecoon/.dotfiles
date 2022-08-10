# swaps right option and right control on all keyboards
hidutil property --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x7000000e7,
      "HIDKeyboardModifierMappingDst":0x7000000e6},
     {"HIDKeyboardModifierMappingSrc":0x7000000e6,
      "HIDKeyboardModifierMappingDst":0x7000000e7}]
}' &> /dev/null


# except on DellKeyboard, when we want to swap the left option and
# control
hidutil property --matching '{"ProductID":0xc52b}' --set '{"UserKeyMapping":
    [{"HIDKeyboardModifierMappingSrc":0x7000000e3,
      "HIDKeyboardModifierMappingDst":0x7000000e2},
     {"HIDKeyboardModifierMappingSrc":0x7000000e2,
      "HIDKeyboardModifierMappingDst":0x7000000e3}]
}' &> /dev/null


