import React from "react";
import { Text, View } from "react-native";
import { SyncIndicator } from "./SyncIndicator";
import { fontSans, tokens } from "../design/tokens";

type Props = {
  date: Date;
  syncState: "synced" | "queued" | "offline";
  queuedCount?: number;
};

const dayShort = ["Nd", "Pn", "Wt", "Śr", "Cz", "Pt", "Sb"];
const monthShort = [
  "sty",
  "lut",
  "mar",
  "kwi",
  "maj",
  "cze",
  "lip",
  "sie",
  "wrz",
  "paź",
  "lis",
  "gru",
];

function formatDate(d: Date): string {
  return `${dayShort[d.getDay()]}, ${d.getDate()} ${monthShort[d.getMonth()]}`;
}

export function TopBar({ date, syncState, queuedCount }: Props) {
  return (
    <View
      style={{
        paddingTop: 14,
        paddingBottom: 14,
        paddingHorizontal: 20,
        backgroundColor: tokens.colors.cream,
      }}
    >
      <View className="flex-row items-end justify-between">
        <View>
          <Text
            style={{
              ...fontSans(700),
              color: tokens.colors.title,
              fontSize: 28,
              lineHeight: 32,
              letterSpacing: -0.4,
            }}
          >
            Mój dzień
          </Text>
          <Text
            style={{
              ...fontSans(500),
              color: tokens.colors.muted,
              fontSize: 14,
              marginTop: 2,
            }}
          >
            {formatDate(date)}
          </Text>
        </View>
        <View style={{ paddingBottom: 4 }}>
          <SyncIndicator state={syncState} queuedCount={queuedCount} />
        </View>
      </View>
    </View>
  );
}
