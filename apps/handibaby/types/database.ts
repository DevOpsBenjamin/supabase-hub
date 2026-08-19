export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.15"
  }
  app_handibaby: {
    Tables: {
      frozen_editions: {
        Row: {
          data: Json
          frozen_at: number
          tournament_public_id: string
        }
        Insert: {
          data: Json
          frozen_at: number
          tournament_public_id: string
        }
        Update: {
          data?: Json
          frozen_at?: number
          tournament_public_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "frozen_editions_tournament_public_id_fkey"
            columns: ["tournament_public_id"]
            isOneToOne: true
            referencedRelation: "tournaments"
            referencedColumns: ["public_id"]
          },
        ]
      }
      matches: {
        Row: {
          duel: number | null
          entered_at: number | null
          id: number
          loser_score: number | null
          phase: string
          rank_in_duel: number | null
          tournament_public_id: string
          winning_side: string | null
        }
        Insert: {
          duel?: number | null
          entered_at?: number | null
          id?: never
          loser_score?: number | null
          phase: string
          rank_in_duel?: number | null
          tournament_public_id: string
          winning_side?: string | null
        }
        Update: {
          duel?: number | null
          entered_at?: number | null
          id?: never
          loser_score?: number | null
          phase?: string
          rank_in_duel?: number | null
          tournament_public_id?: string
          winning_side?: string | null
        }
        Relationships: []
      }
      players: {
        Row: {
          created_at: string
          first_name: string
          id: number
          last_name: string
          name_key: string
        }
        Insert: {
          created_at?: string
          first_name: string
          id?: never
          last_name: string
          name_key: string
        }
        Update: {
          created_at?: string
          first_name?: string
          id?: never
          last_name?: string
          name_key?: string
        }
        Relationships: []
      }
      scores_journal: {
        Row: {
          created_at: string
          duel: number | null
          entry_id: string
          loser_score: number
          operation: string
          phase: string
          previous: Json | null
          rank_in_duel: number | null
          tournament_public_id: string
          winning_side: string
          written_at: number
        }
        Insert: {
          created_at?: string
          duel?: number | null
          entry_id: string
          loser_score: number
          operation: string
          phase: string
          previous?: Json | null
          rank_in_duel?: number | null
          tournament_public_id: string
          winning_side: string
          written_at: number
        }
        Update: {
          created_at?: string
          duel?: number | null
          entry_id?: string
          loser_score?: number
          operation?: string
          phase?: string
          previous?: Json | null
          rank_in_duel?: number | null
          tournament_public_id?: string
          winning_side?: string
          written_at?: number
        }
        Relationships: []
      }
      teams: {
        Row: {
          id: number
          label: string
          player_one_name_key: string
          player_two_name_key: string
          team_index: number
          tournament_public_id: string
        }
        Insert: {
          id?: never
          label: string
          player_one_name_key: string
          player_two_name_key: string
          team_index: number
          tournament_public_id: string
        }
        Update: {
          id?: never
          label?: string
          player_one_name_key?: string
          player_two_name_key?: string
          team_index?: number
          tournament_public_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "teams_player_one_name_key_fkey"
            columns: ["player_one_name_key"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["name_key"]
          },
          {
            foreignKeyName: "teams_player_two_name_key_fkey"
            columns: ["player_two_name_key"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["name_key"]
          },
          {
            foreignKeyName: "teams_tournament_public_id_fkey"
            columns: ["tournament_public_id"]
            isOneToOne: false
            referencedRelation: "tournaments"
            referencedColumns: ["public_id"]
          },
        ]
      }
      tournament_players: {
        Row: {
          id: number
          player_name_key: string
          tournament_public_id: string
        }
        Insert: {
          id?: never
          player_name_key: string
          tournament_public_id: string
        }
        Update: {
          id?: never
          player_name_key?: string
          tournament_public_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "tournament_players_player_name_key_fkey"
            columns: ["player_name_key"]
            isOneToOne: false
            referencedRelation: "players"
            referencedColumns: ["name_key"]
          },
          {
            foreignKeyName: "tournament_players_tournament_public_id_fkey"
            columns: ["tournament_public_id"]
            isOneToOne: false
            referencedRelation: "tournaments"
            referencedColumns: ["public_id"]
          },
        ]
      }
      tournaments: {
        Row: {
          created_at: number
          label: string
          passphrase_hash: string
          public_id: string
          start_date: string
          status: string
        }
        Insert: {
          created_at: number
          label: string
          passphrase_hash: string
          public_id: string
          start_date: string
          status?: string
        }
        Update: {
          created_at?: number
          label?: string
          passphrase_hash?: string
          public_id?: string
          start_date?: string
          status?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      correct_score: {
        Args: {
          p_duel: number
          p_journal_entry_id: string
          p_loser_score: number
          p_phase: string
          p_previous: Json
          p_rank_in_duel: number
          p_tournament_public_id: string
          p_winning_side: string
          p_written_at: number
        }
        Returns: undefined
      }
      record_score: {
        Args: {
          p_duel: number
          p_journal_entry_id: string
          p_loser_score: number
          p_phase: string
          p_rank_in_duel: number
          p_tournament_public_id: string
          p_winning_side: string
          p_written_at: number
        }
        Returns: undefined
      }
      save_player: {
        Args: { p_first_name: string; p_last_name: string; p_name_key: string }
        Returns: undefined
      }
      save_tournament: {
        Args: {
          p_created_at: number
          p_label: string
          p_passphrase_hash: string
          p_public_id: string
          p_start_date: string
          p_status: string
        }
        Returns: undefined
      }
      sync_tournament_bundle: {
        Args: {
          p_frozen_edition?: Json
          p_matches?: Json
          p_players?: Json
          p_teams?: Json
          p_tournament: Json
          p_tournament_players?: Json
        }
        Returns: undefined
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  app_handibaby: {
    Enums: {},
  },
} as const
