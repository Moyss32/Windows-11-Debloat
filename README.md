# Windows-11-Debloat
Um script em powershell (.ps1) que remove com segurança aplicativos desnecessários do Windows 11 Pro (futuramente o home, home single lenguage, e education), desativando a telemetria, otimizando o desempenho e ajustando as configurações de privacidade. **Inclui a criação de um ponto de restauração** e uma interface amigável.

**⚠ Este script deve ser executado como administrador.**

## Como rodar
Para rodar é simples e rápido, siga a estes passos:

1) Baixe ou copie o conteúdo do arquivo de sua preferencia e uso, sendo que todas as versões e suportes seguem o padrão: "debloat-win11-V."versão.windows", onde "versão.windows" é caracteriza, por exemplo, como "V.PRO", "V.HOME", "V.EDUCATION".
</br>
2) Em sua área de trabalho, ou local de sua preferencia, crie um arquivo nomeado de "debloat.txt", e cole o conteúdo, em seguida, modifique a extenção do arquivo de ".txt" para ".ps1" (executavél do windows powershell).

## Execução do Arquivo.
para executar o debloat de forma correta, siga os seguintes passos:
1) Abra o windows powershell como administrador (pressione a tecla `win`, pesquise por `Powershell` no lado direito, clique em `"executar como administrador"`)
</br>
2) Vá até a pasta onde está o arquivo (`cd "C:\caminho\do\script"`).
</br>
3) Execute "`.\debloat.ps1`".

   **Importante**: O windows bloqueia scripts .ps1 por padrão, caso isso aconteça, siga os segintes passos:
   1) Verifique `Get-ExecutionPolicy`, caso retorne `Restricted`, rode: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`.

**Pronto** Selecione a opção melhor para você, e seja feliz, sem o windows consumir muita memória ram e processador.🙂
