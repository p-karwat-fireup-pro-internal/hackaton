import React from "react";
import { Text, View } from "react-native";
import { Icon } from "./Icon";
import { fontSans, tokens } from "../design/tokens";

type Props = {
  state: "synced" | "queued" | "offline";
  queuedCount?: number;
};

function pluralPozycje(n: number): string {
  if (n === 1) return "pozycja";
  const lastTwo = n % 100;
  const last = n % 10;
  if (lastTwo >= 12 && lastTwo <= 14) return "pozycji";
  if (last >= 2 && last <= 4) return "pozycje";
  return "pozycji";
}

function a11yLabel(state: Props["state"], queuedCount: number): string {
  if (state === "synced") return "Synchronizacja: zsynchronizowano";
  if (state === "queued")
    return `Synchronizacja: w kolejce ${queuedCount} ${pluralPozycje(queuedCount)}, czeka na sieć`;
  if (queuedCount > 0)
    return `Tryb offline, ${queuedCount} ${pluralPozycje(queuedCount)} w kolejce`;
  return "Tryb offline";
}

export function SyncIndicator({ state, queuedCount = 0 }: Props) {
  const liveProps = {
    accessibilityLabel: a11yLabel(state, queuedCount),
    accessibilityLiveRegion: "polite" as const,
    accessible: true,
  };

  if (state === "synced") {
    return (
      <View
        className="flex-row items-center"
        style={{ gap: 6 }}
        {...liveProps}
      >
        <View
          style={{
            width: 8,
            height: 8,
            borderRadius: 4,
            backgroundColor: tokens.colors["status-done"],
          }}
        />
        <Text
          style={{
            ...fontSans(500),
            color: tokens.colors.muted,
            fontSize: 13,
          }}
        >
          Zsynchronizowano
        </Text>
      </View>
    );
  }

  if (state === "queued") {
    return (
      <View
        className="flex-row items-center"
        style={{ gap: 6 }}
        {...liveProps}
      >
        <Icon
          name="refresh-cw"
          size={14}
          color={tokens.colors["status-urgent"]}
        />
        <Text
          style={{
            ...fontSans(600),
            color: tokens.colors["status-urgent"],
            fontSize: 13,
          }}
        >
          Czeka na sieć: {queuedCount}
        </Text>
      </View>
    );
  }

  return (
    <View
      className="flex-row items-center"
      style={{ gap: 6 }}
      {...liveProps}
    >
      <Icon name="cloud-off" size={14} color={tokens.colors.body} />
      <Text
        style={{
          ...fontSans(600),
          color: tokens.colors.body,
          fontSize: 13,
        }}
      >
        Offline
        {queuedCount > 0 ? ` · ${queuedCount} w kolejce` : ""}
      </Text>
    </View>
  );
}
