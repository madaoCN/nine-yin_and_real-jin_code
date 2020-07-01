//
//  main.m
//  stringDefine
//
//  Created by exchen on 17/7/15.
//  Copyright © 2017年 sm. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "eXProtect.h"
#import "Base64.h"

#include <unistd.h>
#include <getopt.h>

//产生长度为length的随机字符串
char* genRandomString(int length,int seedSalt)
{
    int flag, i;
    char* string;
    
    srand((unsigned) time(NULL ) + seedSalt);
    if ((string = (char*) malloc(length)) == NULL )
    {
        printf("malloc failed!\n");
        return NULL ;
    }
    
    for (i = 0; i < length - 1; i++)
    {
        flag = rand() % 3;
        switch (flag)
        {
                case 0:
                string[i] = 'A' + rand() % 26;
                break;
                case 1:
                string[i] = 'a' + rand() % 26;
                break;
                //case 2:
                //string[i] = '0' + rand() % 10;
                //break;
            default:
                string[i] = 'x';
                break;
        }
    }
    string[length - 1] = '\0';
    return string;
}  


int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
       
        printf("eXstringDefine 1.0 by exchen.net\n");
        if (argc == 1 ) {
           
            printf("usage: eXstringDefine [-t type] [-k key] [-i inputFile] [-o outputFile]\n");
            printf("example: eXstringDefine -t string -k exchen -i /Users/exchen/Desktop/stringDefine -o /Users/exchen/Desktop/stringDefine.h\n");
            printf("example: eXstringDefine -t class -i /Users/exchen/Desktop/classDefine -o /Users/exchen/Desktop/classDefine.h\n");
            return 0;
        }
        
        int ch;
        const char *pstrType = NULL;
        const char *pstrKey = NULL;
        const char *pstrInFile = NULL;
        const char *pstrOutFile = NULL;
        
        //获取相关的参数
        while((ch = getopt(argc,argv,"t:k:i:o:"))!= -1)
        {
            switch(ch)
            {
                case 't': {
                    
                    pstrType=optarg;
                }
                    break;
                case 'k': pstrKey=optarg; break;
                case 'i': pstrInFile=optarg; break;
                case 'o': pstrOutFile=optarg; break;
                default: printf("parameter error %c\n",ch);
                    
            }
        }
        
        //打开输入文件
        FILE *fp_input_file = fopen(pstrInFile, "rt");
        if (!fp_input_file) {
            printf("Input file open error\n");
            return 0;
        }
        
        remove(pstrOutFile);  //删除输出文件
        
        //打开输出文件
        FILE *fp_output_file = fopen(pstrOutFile, "wt");
        if (!fp_output_file) {
            printf("Output file open error\n");
            return 0;
        }
        char strBuf[1024] = {0};
        int line_count = 0;
        
        //stringDefine 过程
        while (fgets(strBuf, 1024, fp_input_file))
        {
            //去掉换行符
            long nlen = strlen(strBuf);
            if (strBuf[nlen-1] == '\n'){
                
                strBuf[nlen-1] = '\0';
            }
            if (strBuf[nlen-1] == '\r'){
                
                strBuf[nlen-1] = '\0';
            }
            
            line_count++;
            
            char strText[1024] = {0};
            
            //判断 type，string 为字符串加密，class 为类方法名称混淆
            if (strcmp(pstrType, "string") == 0) {
                
                NSString *strName = [NSString stringWithUTF8String:strBuf];
                
                NSMutableString* strDefName = [[NSMutableString alloc] initWithString:strName];
                
                //由于变量名不允许有特殊符号，所以得替换一下特殊符号
                [strDefName replaceOccurrencesOfString:@"." withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"/" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@":" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"?" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"-" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"=" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"&" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"'" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"<" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@">" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                [strDefName replaceOccurrencesOfString:@"=" withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDefName.length)];
                
                const char *pDefName = [strDefName UTF8String];
                
                //加密字符串
                if (pstrKey == nil) {
                    
                    printf("key is null\n");
                }
                NSString *strKey = [NSString stringWithUTF8String:pstrKey];
                eXProtect *protect = [[eXProtect alloc] init];
                NSString *strEncrypt =  [protect AESEncryptBase64: strName :strKey];
                
                const char *pEncryptName = [strEncrypt UTF8String];
                sprintf(strText,"#define eXString_%s [eXProtect AESDecrypt:@\"%s\"] //%s",pDefName,pEncryptName,strBuf);
            }
            else if(strcmp(pstrType, "class") == 0)
            {
                char *strRandom = genRandomString(15,line_count);  //产生随机字符串
                sprintf(strText,"#define %s %s //%s",strBuf,strRandom,strBuf);
            }
            else
            {
                printf("type error\n");
                return 0;
            }
            
            fwrite(strText,strlen(strText),1,fp_output_file);
            fwrite("\r\n",strlen("\r\n"),1,fp_output_file);
        }
            

    
        fclose(fp_input_file);
        fclose(fp_output_file);

        printf("The number of successful stringDefine has %d, Done.\n",line_count);
    }
    return 0;
}
