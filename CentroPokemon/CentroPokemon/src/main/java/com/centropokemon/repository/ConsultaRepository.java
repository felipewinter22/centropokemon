package com.centropokemon.repository;

import com.centropokemon.model.Consulta;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ConsultaRepository extends JpaRepository<Consulta, Integer> {
    List<Consulta> findByTreinadorIdOrderByDataHoraAsc(Integer treinadorId);
}