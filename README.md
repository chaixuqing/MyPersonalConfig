# MyPersonalConfig
This is my personal config in linux.


# awesome software for windows
1. smallpdf
2. X-PDF-Viewer
3. sumatraPDf
4. MobaXterm
5. 语雀
6. Bandizip
7. CCleaner
8. Clash for windows
9. 滴答清单
10. everything
11. f.lux
12. chrome
13. IDM
14. motrix
15. DeskPins
16. Ditto
17. HoneyView
18. MacType
19. Mathpix Snipping Tool
20. MiniConda
21. Notepad++
22. PotPlayer
23. Typora
24. 火绒
25. 坚果云
26. 网易邮箱大师 
 
# some utils in ubuntu
1. fzf
2. tldr
3. tree
4. broot
5. nnn
6. shellcheck
7. ripgrep
8. fd
9. fasd
10. autojump

## 中文 man 文档
```bash
wget https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/manpages-zh/manpages-zh-1.5.1.tar.gz
tar zxvf manpages-zh-1.5.1.tar.gz
cd manpages-zh-1.5.1
./configure --prefix=/usr/local/zhman --disable-zhtw
make && make install
alias cman='man -M /usr/local/zhman/share/man/zh_CN'
source ~/.zshrc
```
