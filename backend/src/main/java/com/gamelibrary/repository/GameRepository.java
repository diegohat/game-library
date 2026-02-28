package com.gamelibrary.repository;

import com.gamelibrary.model.Game;
import com.gamelibrary.model.GameStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface GameRepository extends JpaRepository<Game, Long> {

    List<Game> findByUserId(Long userId);

    List<Game> findByStatus(GameStatus status);

    List<Game> findByUserIdAndStatus(Long userId, GameStatus status);
}
