FROM archlinux:latest
RUN pacman -Syu --needed sed gnupg pass neomutt lynx <<<y
RUN useradd -m user1
WORKDIR /home/user1
USER user1
CMD ["bash"]
