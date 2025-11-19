package com.centropokemon.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SiteController {

    @GetMapping({"/", "/Pokemon", "/inicio"})
    public String home() {
        return "forward:/Pokemon.html";
    }

    @GetMapping({"/pokedex-anime", "/pokedex"})
    public String pokedex() {
        return "forward:/pokedex-anime.html";
    }

    @GetMapping({"/login"})
    public String login() {
        return "forward:/login.html";
    }

    @GetMapping({"/cadastro"})
    public String cadastro() {
        return "forward:/cadastro.html";
    }

    @GetMapping({"/centro"})
    public String centro() {
        return "redirect:/Pokemon.html#centro";
    }

    @GetMapping({"/sobre"})
    public String sobre() {
        return "redirect:/Pokemon.html#sobre";
    }
}