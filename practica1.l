%option noyywrap

%{
  #include <stdlib.h>

  int numApertura = 0;
  int numCierre = 0;
  int tagsAtributos = 0;
  int numAtributos = 0; 
  int simples = 0;
  int vacios = 0;
  int numCaracteres = 0;

  void contar_caracteres(){
    int j,i;
    i = 0;
    j = 1;
    while(i < strlen(yytext)){
      if (yytext[i] == '<'){
        j = 1;
      }
      if(j == 0)numCaracteres++;
      if(yytext[i] == '>')j = 0;
      
      i++;
    }
  }

  int tagsCoinciden(){
    int result = 0,salir = 0, j;
    char nombreApertura[50];

    int i = 0;
    while(i < strlen(yytext) && salir != 1){
      if(yytext[i] == '<' && yytext[i + 1] != '/'){
        j = 0;
        i++;
        while(yytext[i] != ' ' && yytext[i] != '>'){
          nombreApertura[j] = yytext[i];
          j++;
          i++;
        }
      }

      if(yytext[i] == '<' && yytext[i + 1] == '/'){
        j = 0;
        i+=2;
        while(yytext[i] != '>' && salir != 1){
          if(nombreApertura[j] != yytext[i])
            salir = 1;
          else{
            j++;
            i++;
          }
        }
      }
      i++;
    }

    if(salir == 0)result = 1;
    return result;
  }

  

%}

texto [^<>&'"]+
nombreTag [a-zA-Z0-9_ ]*
atributo [ ]+{nombreTag}[ ]*[=][ ]*['"]{texto}['"][ ]*
tagApertura [<]{nombreTag}{atributo}*[>]
tagCierre [<][/]{nombreTag}[>]
elemSimple {tagApertura}{texto}{tagCierre}  
elemVacio {tagApertura}{tagCierre}

%%

{elemSimple}    { numApertura++; simples++; numCierre++;
                  for(int i = 0; i < strlen(yytext); i++){
                    if(yytext[i] == '=')numAtributos++;
                  }
                  contar_caracteres();
                  if(tagsCoinciden() == 0)printf("ERROR. Los tags de apertura y cierre no coinciden\n");
                }

{elemVacio}     { numApertura++; vacios++; numCierre++;
                  for(int i = 0; i < strlen(yytext); i++){
                    if(yytext[i] == '=')numAtributos++;
                  }
                  if(tagsCoinciden() == 0)printf("ERROR. Los tags de apertura y cierre no coinciden\n");
                }

%%

int main(int argc, char **argv)
{
  if(argc > 1) {
    if(!(yyin = fopen(argv[1], "r"))) {
      perror(argv[1]);
      return EXIT_FAILURE;
    }
  }
  
  yylex();
  printf("Tags Aperutra = %d\nTags Ciere = %d\nElementos Simples = %d\nElementos vacios = %d\nNum Atributos = %d\nNum Caracteres = %d\n", 
                            numApertura, numCierre, simples, vacios, numAtributos,numCaracteres);
}