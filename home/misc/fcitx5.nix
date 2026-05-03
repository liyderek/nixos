{
  i18n.inputMethod = {
    fcitx5.addons = [ ];
  };

  xdg.configFile."fcitx5/profile".text = ''
    [Groups/0]
    # Group name
    Name=Default
    # Layout
    Layout=
    # Default Input Method
    DefaultIM=pinyin

    [Groups/0/Items/0]
    Name=keyboard-us
    Layout=

    [Groups/0/Items/1]
    Name=pinyin
    Layout=

    [GroupOrder]
    0=Default
  '';

  xdg.configFile."fcitx5/conf/pinyin.conf".text = ''
    [Behavior]
    PreeditInCommitMode=False
    UseV=False
    UseEnglishInputMethod=True
    CommitWhenSelectByCandidateNumber=True
    DeleteCandidate=False
    SendRawPreedit=False

    [CloudPinyin]
    Enable=False

    [Other]
    PageSize=5
    SpellHint=True
  '';
}
