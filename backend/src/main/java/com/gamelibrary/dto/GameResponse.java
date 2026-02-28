package com.gamelibrary.dto;

import com.gamelibrary.model.Game;
import com.gamelibrary.model.GameStatus;

import java.math.BigDecimal;
import java.time.Instant;

public record GameResponse(
        Long id,
        String title,
        String platform,
        String genre,
        GameStatus status,
        BigDecimal personalRating,
        String coverUrl,
        Instant createdAt,
        Instant updatedAt) {
    public static GameResponse from(Game game) {
        return new GameResponse(
                game.getId(),
                game.getTitle(),
                game.getPlatform(),
                game.getGenre(),
                game.getStatus(),
                game.getPersonalRating(),
                game.getCoverUrl(),
                game.getCreatedAt(),
                game.getUpdatedAt());
    }
}
