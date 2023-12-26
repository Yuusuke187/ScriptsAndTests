Describe "Set-Rot13Cipher" {
    It "Sets 13, returns 'n'" {
        $result = Set-Rot13Cipher(13)
        $result | Should -Be "n"
    }
}

Describe "Set-Rot13Cipher" {
    It "Sets 1000, returns 'm'" {
        $result = Set-Rot13Cipher(1000)
        $result | Should -Be "m"
    }
}
